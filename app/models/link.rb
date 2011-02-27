# -*- coding: utf-8 -*-
class Link < Post
  field :url
  field :title
  field :content

  attr_accessible :url, :title, :content

  validates_presence_of :url,
    :message => "请输入链接"
  validates_length_of :url,
    :minimum => 3,
    :maximum => 100,
    :too_short => "网址格式不正确",
    :too_long => "网址格式不正确"

  validates_presence_of :title,
    :message => "请输入标题"
  validates_length_of :title,
    :maximum => 60,
    :too_long => "标题太长了"

end
