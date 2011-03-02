# -*- coding: utf-8 -*-
require 'uri'

class Link < Post
  field :url
  field :title
  field :content

  attr_accessible :url, :title, :content

  before_validation :convert_to_http

  validates_presence_of :url,
    :message => "请输入链接"

  private

  def convert_to_http
    orig_url = self.url
    parsed = URI.parse orig_url
    self.url = 'http://' + orig_url if parsed.instance_of? URI::Generic
  end

end
