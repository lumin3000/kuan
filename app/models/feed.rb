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
  #一个feed第一次被导入时，全部抓取（Time.at(0)), 之后只抓取更新，
  #反映在产品上就是第一个导入此feed的用户会看到之前的feed，而后续用户只能得到更新
  field :fetched_at, :type => Time, :default => lambda {Time.at(0)}

  validates_presence_of :uri
  validates_uniqueness_of :uri

  #Repeat code, waitting for moving PROCESS_SPEC from ImageController to Image model
  PROCESS_PHOTO = {
    :large => [500, 0],
    :medium => [180, 300],
    :small => [60, 60],
    :'400' => [400, 0],
    :'250' => [250, 0],
    :'100' => [100, 0],
    :'150' => [150, 150],
    :'75' => [75, 75],
  }

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

    def transfer_all
      @@logger ||= Logger.new("#{Rails.root.to_s}/log/feeds_transfer.log")
      @@logger.info "Beginning at #{Time.now}"
      order_by(:imported_count).each {|feed| feed.transfer}
      @@logger.info "Finishing at #{Time.now}"
    end
  end

  def transfer
    @@logger.info "Transfer #{uri} at #{Time.now}"
    blogs = Blog.where("import_feeds.feed_id" => id)
    destroy and return if blogs.blank?

    begin
      u = URI.parse uri
      u.open("If-Modified-Since" => fetched_at.to_s(:rfc822)) do |io|
        rss = RSS::Parser.parse io.read, false
        rss.items.each do |item|
          blogs.each do |blog| 
            post_item_to_blog item, blog, rss.channel if item.date > fetched_at
          end
        end
      end
    rescue OpenURI::HTTPError => ex
      return if ex.io.status[0] == "304"
      @@logger.warn "Unvalid #{uri} [#{ex}] at #{Time.now}"
      return
    rescue Exception => e
      @@logger.error "Exception #{uri} [#{e}] at #{Time.now}"
      return
    end

    update_attributes(:fetched_at => Time.now)
    @@logger.info "Fetched #{uri} at #{Time.now}"
  end

  private

  def post_item_to_blog(item, blog, channel)
    import_feed = blog.import_feeds.find_by_id(id).first

    post_new = send import_feed.as_type.to_s, item
    if post_new.nil?
      @@logger.warn "Item error #{uri} #{item.title} #{uri}"
      return
    end

    if import_feed.as_type != :link
      post_new.content ||= ""
      post_new.content += %(<br /><div>来自: <a href="#{item.link}">#{channel.title}</a>)
      post_new.content += %( by #{item.dc_creator}) unless item.dc_creator.blank?
      post_new.content += %(</div>)
    end

    post_new.blog = blog
    post_new.author = import_feed.author
    post_new.created_at = item.date

    unless post_new.valid?
      @@logger.warn "Item unvalid #{uri} #{item.title} #{uri}"
      return
    end

    post_new.save
  end

  def text(item)
    Text.new(:title => item.title,
             :content => item.description)
  end

  def link(item)
    Link.new(:title => item.title,
             :url => item.link)
  end

  def pics(item)
    doc = Nokogiri.HTML item.description
    photos = doc.xpath('//img').reduce [] do |suc_photos, img_e|
      begin
        image = Image.create_from_url img_e.attribute('src').value, PROCESS_PHOTO
        suc_photos << Photo.new(:image => image, :desc => "") unless image.nil?
      rescue Exception => e
      end
      suc_photos
    end
    return if photos.blank?
    Pics.new(:photos => photos)
  end

end
