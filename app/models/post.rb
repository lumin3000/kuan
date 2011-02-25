# encoding: utf-8

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :blog
  referenced_in :author, :class_name => 'User'
  attr_accessible :blog, :author, :author_id, :blog_id

  validates_presence_of :blog, :author
  validate :posted_to_editable_blogs, :if => :new_record?
  validate :editable_by?

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

  def editable_by?(user = nil?)
    return false if self.author_id.nil?
    user ||= User.find(self.author_id)
    self.author == user || user.own?(self.blog)
  end

  private

  def posted_to_editable_blogs
    return if author_id.nil? || blog_id.nil?
    author = User.find(self.author_id)
    blog = Blog.find(self.blog_id)
    errors.add :blog, "放开那博客" unless author.blogs.include? blog
  end
end
