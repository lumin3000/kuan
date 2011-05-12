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
    blogs = Blog.where("import_feeds.feed_id" => id).group_by do |blog|
      blog.import_feeds.find_by_id(id).first.is_new? ? :new : :old
    end

    http = URI.parse uri
    begin
      rss = RSS::Parser.parse http, false
    rescue Exception => e
      #log unvalid feed uri
      return
    end

    rss.items.each do |item|
      blogs[:new].each { |blog| post_item_to_blog item, blog, rss.channel }
      blogs[:old].each { |blog| post_item_to_blog item, blog, rss.channel } if item.pubDate > fetched_at
    end

    blogs[:new].each do |blog|
      blog.import_feeds.find_by_id(id).first.update_attributes :is_new => false
    end
  end

  private

  def post_item_to_blog(item, blog, channel)
    import_feed = blog.import_feeds.find_by_id(id).first
    #:pics.to_s.camelize.constantize.new
    # post_new = case post["type"]
    #            when 1
    #              Text.new(:content => post["post"])
    #            when 2
    #              trans_pics post["post"]
    #            when 3
    #              Text.new(:title => post["post"]["title"],
    #                       :content => post["post"]["content"])
    #            when 4
    #              Link.new(:title => post["post"]["title"],
    #                       :url => post["post"]["url"],
    #                       :content => post["post"]["desc"])
    #            when 5
    #              Video.new(:content => post["post"]["desc"],
    #                        :url => post["post"]["src"],
    #                        :thumb => post["post"]["img"],
    #                        :site => post["post"]["from"])
    #            else
    #              nil
    #            end
    # return if post_new.nil?
    # post_new.blog = Blog.find_by_uri! @moving.to_uri
    # post_new.author = @moving.user
    # post_new.created_at = Time.at(post["pubtime"]).utc
    # return unless post_new.valid?
    # post_new.save
  end

end
