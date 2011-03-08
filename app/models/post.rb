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

  field :parent_id
  field :ancestor_id
  index :ancestor_id
  field :repost_count, :type => Integer, :default => 0
  field :favor_count, :type => Integer, :default => 0

  attr_accessible :blog, :author, :author_id, :blog_id, :created_at, :comments, :parent

  validates_presence_of :author_id
  validates_presence_of :blog_id, :message => "请选择要发布到的页面"

  validate :posted_to_editable_blogs, :if => :new_record?

  before_destroy :clean_comments_notices
  before_create :type_setter
  after_create :ancestor_reposts_inc, :update_blog

  def haml_object_ref
    "post"
  end

  def type
    self._type.downcase
  end

  # about the repost , parent and ancestor
  def parent=(parent)
    self.created_at = self.updated_at = Time.now
    return if parent.nil?
    self.parent_id = parent.id
    self.ancestor_id = parent.ancestor.nil? ? parent.id : parent.ancestor.id
  end

  def parent
    Post.criteria.id(parent_id).first unless parent_id.nil?
  end

  def ancestor
    return nil if ancestor_id.nil?
    a = Post.criteria.id(ancestor_id).first
    a ||= parent
  end

  def self.new(args = {})
    type = args.delete :type
    return super if type.nil?
    klass = Object.const_get type.capitalize
    (self.subclasses.include? klass) ? klass.new(args) : nil
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

  def editable_by?(user)
    return false if user.nil?
    author == user || blog.customed?(user)
  end

  def favored_by?(user)
    not user.nil? and user.favor_posts.include? self
  end

  def favor_count_inc
    favor_count.nil? ? update_attributes(:favor_count => 1) : inc(:favor_count, 1)
  end

  def favor_count_dec
    favor_count.nil? ? update_attributes(:favor_count => 0) : inc(:favor_count, -1)
  end

  def notify_watchers(comment)
    watchers = self.watchers
    watchers.delete comment.author
    watchers.each do |w|
      w.insert_unread_comments_notices!(self)
    end
  end

  def watchers
    watchers =  self.comments.map {|f| f.author}
    watchers << self.author
    watchers.uniq
  end

  private

  def update_blog
    blog.update_attributes(:posted_at => created_at)
  end

  def type_setter
    self._type = self.class.to_s
  end

  def clean_comments_notices
    watchers.each do |u|
      u.comments_notices.destroy_all(:conditions => { :post_id => self.id })
    end
  end

  def posted_to_editable_blogs
    return if author_id.nil? || blog_id.nil?
    author = User.find(self.author_id)
    blog = Blog.find(self.blog_id)
    errors.add :blog, "放开那博客" unless author.blogs.include? blog
  end

  def sanitize_content
    self.content = Post.tag_filter(self.content)
  end

  def ancestor_reposts_inc
    unless ancestor.nil?
      if ancestor.repost_count.nil?
        ancestor.update_attributes(:repost_count => 1)
      else
        ancestor.inc :repost_count, 1
      end
    end
  end

end
