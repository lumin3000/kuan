# -*- coding: utf-8 -*-
require 'uri'

class Link < Post
  field :url
  field :title
  field :content

  attr_accessible :url, :title, :content

  before_validation :convert_to_http
  before_validation :sanitize_content

  validates_presence_of :url,
  :message => "请输入有效链接"

  private

  def convert_to_http
    begin
      parsed = URI.parse url
      self.url = 'http://' + url if parsed.instance_of? URI::Generic
    rescue Exception => e
      self.url = nil
    end
  end

end
