# encoding: utf-8

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :blog
  referenced_in :author, :class_name => 'User'
  attr_accessible :blog, :author, :author_id, :blog_id

  validates_presence_of :blog_id, :author_id
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

  private

  def posted_to_editable_blogs
    return if author_id.nil? || blog_id.nil?
    author = User.find(self.author_id)
    blog = Blog.find(self.blog_id)
    errors.add :blog, "放开那博客" unless author.blogs.include? blog
  end
end
