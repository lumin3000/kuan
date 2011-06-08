# -*- coding: utf-8 -*-
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content
  embedded_in :post, :inverse_of => :comments
  referenced_in :author, class_name: 'User'
  attr_accessible :content, :post, :author, :author_id

  validates_presence_of :content, message: "回复不能为空"
  validates_length_of :content,
    minimum: 1,
    too_short: "写几个字吧"

  # 2011-6-8 升级mongoid 2.0.2后，在after_create时触发notify_watchers会产生奇怪现象
  # post.comments无法持久化(post.reload后comments为空), 且comment对象会不可解释地被插入user.comments_notices
  # 怀疑是mongoid的callback与embeds_many共同作用的bug导致，暂时移除此after_create,改为手动触发post.notify_watchers
  
  # after_create :notify_watchers

  def manageable_by?(user)
    return false if user.nil?
    author == user || post.author == user || post.blog.customed?(user)
  end

  protected
  
  # def notify_watchers
  #   unless self.post.nil?
  #     self.post.notify_watchers self
  #   end
  # end
end
