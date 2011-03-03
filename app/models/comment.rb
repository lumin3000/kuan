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
    :minium => 1,
    :maximum => 1000,
    :too_short => "写几个字吧",
    :too_long => "最多%{count}个字"

end
