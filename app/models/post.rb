# encoding: utf-8
require 'nokogiri'

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :blog
  referenced_in :author, :class_name => 'User'
  embeds_many :comments

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
    MALICIOUS_CSS = /expression|url/
    SPECIAL_ATTR = {
      'style' => lambda { |css|
        rules = css.split /\s*;\s*/
        rules.reject! {|r| r.match MALICIOUS_CSS}
        rules.join('; ')
      },
    }
    N = Nokogiri::XML::Node

    def tag_filter(content)
      raise "Expecting a string" unless content.kind_of? String
      tree = Nokogiri::HTML.fragment(content)
      tree.traverse do |n|
        case n.type
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
    self.author == user || user.own?(self.blog)
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
