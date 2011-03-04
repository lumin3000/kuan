# encoding: utf-8

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

  def posted_to_editable_blogs
    return if author_id.nil? || blog_id.nil?
    author = User.find(self.author_id)
    blog = Blog.find(self.blog_id)
    errors.add :blog, "放开那博客" unless author.blogs.include? blog
  end
end
