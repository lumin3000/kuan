# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'
require 'nokogiri'

class Video < Post

  field :url
  field :player
  field :thumb
  field :content
  field :site

  before_validation :sanitize_content

  validates_presence_of :url
  validates_presence_of :player, :message =>  "不是正确的格式"
  attr_accessible :content, :url, :site, :thumb

  FETCH_SITES = [:youku, :tudou, :ku6]

  def url=(url)
    begin
      super(html url)
      http = URI.parse self.url
      raise URI::InvalidURIError unless http.kind_of? URI::HTTP
    rescue Exception
      return self.errors.add :url, "不是正确的格式"
    end

    begin
      http.open do |io|
        if io.content_type == "application/x-shockwave-flash"
          return self.player = self.url
        end

        FETCH_SITES.each do |m|
          send m, io do |p, t, c, s|
            self.player, self.thumb, self.site = p, t, s
            self.content = c if self.content.blank?
          end
          return if valid?
        end
      end
    rescue Exception => e
      return self.errors.add :url, "无法识别此地址"
    end
  end

  private

  def html(code)
    Nokogiri::HTML.parse(code).xpath('//embed').each do |embed|
      return embed.attributes["src"].value
    end
    code
  end

  def youku(io)
    return unless io.base_uri.host.include? "youku.com"
    id = io.base_uri.path.split('/').last.split('.').first.split('_').last
    return if id.blank?
    p = "http://player.youku.com/player.php/sid/#{id}/v.swf"
    doc = Nokogiri::HTML io, nil, io.charset
    t = doc.css('a#download').first.attributes["href"].value.split('|').last
    c = doc.xpath('//title').first.content
    yield p, t, c, "优酷"
  end

  def tudou(io)
    return unless io.base_uri.host.include? "tudou.com"
    id = io.base_uri.path.split('/').last
    return if id.blank?
    p = "http://www.tudou.com/v/#{id}/v.swf"
    doc = Nokogiri::HTML io, nil, io.charset
    m = /thumbnail\s*?=\s*?'(.*?)'/.match doc.xpath('//script').first.content
    t = m ? m[1] : nil
    c = doc.xpath('//title').first.content
    yield p, t, c, "土豆"
  end

  def ku6(io)
    return unless io.base_uri.host.include? "ku6.com"
    id = io.base_uri.path.split('/').last.split('.').first
    return if id.blank?
    p = "http://player.ku6.com/refer/#{id}/v.swf"
    doc = Nokogiri::HTML io, nil, io.charset
    t = doc.css('span.s_pic').first.content
    c = doc.xpath('//title').first.content
    yield p, t, c, "酷6"
  end

end
