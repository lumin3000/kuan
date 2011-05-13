# -*- coding: utf-8 -*-
require 'open-uri'
require 'nokogiri'
require 'rss'

class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :uri
  field :imported_count, :type => Integer, :default => 0
  index :imported_count
  field :fetched_at, :type => Time, :default => lambda {Time.at(0)}

  validates_presence_of :uri
  validates_uniqueness_of :uri

  class << self
    def find_or_create_by_uri(uri)
      checked_uri, title = self::check_uri uri
      return nil if checked_uri.nil?
      feed = self::find_or_create_by :uri => checked_uri
      feed.update_attributes :title => title
      feed
    end

    def check_uri(uri, is_strict = false)
      uri = "http://" + uri unless uri =~ /^http:\/\//
      begin
        http = URI.parse uri
      rescue Exception => e
        return nil
      end

      begin
        rss = RSS::Parser.parse http, false
        return uri, rss.channel.title
      rescue Exception => e
        return nil if is_strict
        http.open do |io|
          doc = Nokogiri::HTML io, nil, io.charset
          rss_element = doc.xpath('//link[@rel="alternate"][@type="application/rss+xml"]').first
          return nil if rss_element.nil?
          uri = rss_element.attribute("href").value
          check_uri uri, true
        end
      end
    end
  end

  def transfer
    blogs = Blog.where("import_feeds.feed_id" => id)
    destroy and return if blogs.blank?
    
    http = URI.parse uri
    begin
      rss = RSS::Parser.parse http, false
    rescue Exception => e
      #log unvalid feed uri
      return
    end

    rss.items.each do |item|
      blogs.each do |blog|
        post_item_to_blog item, blog, rss.channel if item.date > fetched_at
      end
    end

  end

  private

  def post_item_to_blog(item, blog, channel)
    import_feed = blog.import_feeds.find_by_id(id).first
    
    post_new = send import_feed.as_type.to_s, item
    #log unvalid item
    return if post_new.nil?

    if import_feed.as_type != :link
      post_new.content += %(<br /><div><span>来自: <a href="#{item.link}">#{channel.title}</a></span>)
      post_new.content += %(<span>作者: #{item.dc_creator}</span>) unless item.dc_creator.blank?
      post_new.content += %(</div>)
    end

    post_new.blog = blog
    post_new.author = import_feed.author
    post_new.created_at = item.date

    #log unvalid item
    return unless post_new.valid?
    
    post_new.save
  end

  def text(item)
    Text.new(:title => item.title,
             :content => item.description)
  end

end
