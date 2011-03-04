# encoding: utf-8
require 'nokogiri'
require 'uri'

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :blog, :index => true
  referenced_in :author, :class_name => 'User', :index => true
  embeds_many :comments
  index :created_at

  attr_accessible :blog, :author, :author_id, :blog_id, :created_at, :comments

  validates_presence_of :author_id
  validates_presence_of :blog_id, :message => "请选择要发布到的页面"

  validate :posted_to_editable_blogs, :if => :new_record?

  def haml_object_ref
    "post"
  end

  def type=(t)
    self._type = t.capitalize
  end

  def type
    self._type.downcase
  end

  def self.infer_type(t)
    klass = Object.const_get t.capitalize
    if self.subclasses.include? klass
      klass
    else
      nil
    end
  end

  def self.default_type
    "text"
  end

  class << self
    TAG_WHITE_LIST = %w{pre code tt a p s i b div span table thead tbody tfoot tr th td h1 h2 h3 h4 h5 h6 img strong em br hr ul ol li blockquote cite sub sup ins}
    ATTR_WHITE_LIST = %w{href title src style width height alt}
    MALICIOUS_CSS = Regexp.union(/e\s*x\s*p\s*r\s*e\s*s\s*s\s*i\s*o\s*n/i, /u\s*r\s*l/i)
    LEGAL_URL = lambda { |url|
      begin
        if URI.parse(url).kind_of? URI::HTTP
          url
        else
          ""
        end
      rescue
        ""
      end
    }
    SPECIAL_ATTR = {
      'style' => lambda { |css|
        rules = css.split /\s*;\s*/
        rules.reject! {|r| r.match MALICIOUS_CSS}
        rules.join('; ')
      },
      'src' => LEGAL_URL,
      'href' => LEGAL_URL,
    }
    N = Nokogiri::XML::Node

    def tag_filter(content)
      return nil if content.blank?
      raise "Expecting a string" unless content.kind_of? String
      tree = Nokogiri::HTML.fragment(content)
      tree.traverse do |n|
        case n.type
        when N::TEXT_NODE
          next if has_parent?(n, 'a')
          n.replace Nokogiri::HTML.fragment(auto_link!(n.to_html))
        when N::ELEMENT_NODE
          n.unlink unless TAG_WHITE_LIST.include? n.name
          n.each do |k, v|
            n.delete k unless ATTR_WHITE_LIST.include? k
            n[k] = SPECIAL_ATTR[k].call v if SPECIAL_ATTR.has_key? k
          end
        end
      end
      tree.to_html
    end

    def auto_link!(str)
      links = URI.extract str
      links.each do |link|
        str[link] = "<a href=\"#{link}\">#{link}</a>"
      end
      str
    end

    def has_parent?(node, parent_name)
      while node = node.parent
        return true if node.name == parent_name
      end
      false
    end
  end

  # Must stub this out
  def photos(*args)
  end

  # Also stubbed
  def error
  end
  def error=
  end

  def editable_by?(user)
    return false if user.nil?
    author == user || blog.customed?(user)
  end

  private

  def posted_to_editable_blogs
    return if author_id.nil? || blog_id.nil?
    author = User.find(self.author_id)
    blog = Blog.find(self.blog_id)
    errors.add :blog, "放开那博客" unless author.blogs.include? blog
  end

  def sanitize_content
    self.content = Post.tag_filter(self.content)
  end
end
