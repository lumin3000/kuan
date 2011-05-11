# -*- coding: utf-8 -*-
require 'spec_helper'

describe Feed do
  describe "Importing a feed" do
    before :each do
      @user = Factory.build(:user_unique)
      @blog = @user.create_primary_blog!
    end

    after :each do
      Blog.delete_all
      Feed.delete_all
    end

    it "should record an importing relationship" do
      feed_uri = "http://9tonight.blogbus.com/index.rdf"
      type = :pic
      @blog.import!(feed_uri, type).should be_true
      @blog.reload
      @blog.import_feeds.first.as_type.should == type
      @blog.import_feeds.first.should be_is_new
      @blog.import_feeds.first.feed.uri.should == feed_uri
      @blog.import_feeds.first.feed.imported_count.should == 1
      @blog.import_feeds.first.feed.title.should == "Silence" 
    end

    it "should record two importing relationship" do
      feed_uri = "http://blog.sina.com.cn/twocold"
      type = :text
      @blog.import!(feed_uri, type).should be_true
      @blog.reload
      @blog.import_feeds.first.as_type.should == type
      @blog.import_feeds.first.should be_is_new
      @blog.import_feeds.first.feed.uri.should == "http://blog.sina.com.cn/rss/1191258123.xml"
      @blog.import_feeds.first.feed.imported_count.should == 1
      @blog.import_feeds.first.feed.title.should == "韩寒"
      blog2 = Factory.build :blog_unique
      @user.follow! blog2, "founder"
      blog2.import!(feed_uri, type).should be_true
      blog2.import_feeds.first.feed.should == @blog.import_feeds.first.feed
      blog2.import_feeds.first.should be_is_new
      Feed.count.should == 1
    end

    it "should accept an uri which omit http protocol" do
      uri = "moehuaji.diandian.com/rss"
      feed = Feed.find_or_create_by_uri uri
      feed.should_not be_nil
    end

    it "should accept an uri which have alternative link" do
      uri = "9tonight.blogbus.com"
      feed = Feed.find_or_create_by_uri uri
      feed.should_not be_nil
      feed.uri.should == "http://9tonight.blogbus.com/index.rdf"
      feed.title.should == "Silence"
    end

    it "should reject an invalid uri" do
      uri = "9tonightblogbuscom"
      feed = Feed.find_or_create_by_uri uri
      feed.should be_nil
      @blog.import!(uri, :pic).should be_false
      @blog.errors.should be_has_key(:import_feed_uri)
    end 

    it "should not accept same import feed" do
      feed_uri = "http://9tonight.blogbus.com/index.rdf"
      @blog.import!(feed_uri, :pic).should be_true
      @blog.import!(feed_uri, :text).should be_false
      @blog.errors.should be_has_key(:import_feed_uri)
    end

    it "should not accept >3 import feeds" do
      @blog.import!("http://9tonight.blogbus.com", :pic).should be_true
      @blog.import!("moehuaji.diandian.com", :pic).should be_true
      @blog.import!("http://hi.baidu.com/%C2%BD%BE%B0%EC%AA", :pic).should be_true
      @blog.import!("http://blog.sina.com.cn/twocold", :pic).should be_false
      @blog.errors.should be_has_key(:import_feed_uri)
    end
  end
end
