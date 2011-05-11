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
        http.open do |io|
          begin
            rss = RSS::Parser.parse io.read, false
            return uri, rss.channel.title
          rescue Exception => e
            return nil if is_strict
            io.rewind
            doc = Nokogiri::HTML io, nil, io.charset
            rss_element = doc.xpath('//link[@rel="alternate"][@type="application/rss+xml"]').first
            return nil if rss_element.nil?
            uri = rss_element.attribute("href").value
            check_uri uri, true
          end
        end
      rescue Exception => e
        nil
      end
    end

  end

end
