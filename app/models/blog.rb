# encoding: utf-8

class Blog < Post
  field :title
  field :content

  attr_accessible :title, :content

  validates_length_of :content,
    :minimum => 1,
    :too_short => "写点什么吧",
end
