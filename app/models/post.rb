# encoding: utf-8

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :blog

  referenced_in :author, :class_name => 'User'
  attr_accessible :blog, :author, :author_id, :blog_id

  validates_presence_of :blog, :author

  validate :posted_to_editable_blogs, :if => :new_record?

  def haml_object_ref
    "post"
  end

  alias type= _type=
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

  def editable_by?(user)
    self.author == user || user.own?(self.blog)
  end

  private

  def posted_to_editable_blogs
    author = User.find(self.author_id)
    blog = Blog.find(self.blog_id)
    raise "放开那博客" unless author.blogs.include? blog
  end
end
