# -*- coding: utf-8 -*-
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content
  embedded_in :post, :inverse_of => :comments
  referenced_in :author, :class_name => 'User'
  attr_accessible :content, :post, :author, :author_id

  validates_presence_of :content, :message => "回复不能为空"
  validates_length_of :content,
    :minimum => 1,
    :too_short => "写几个字吧"

  after_create :notify_watchers

  def manageable_by?(user)
    return false if user.nil?
    author == user || post.author == user || post.blog.customed?(user)
  end

  protected
  
  def notify_watchers
    unless self.post.nil?
      self.post.notify_watchers self
    end
  end
end
