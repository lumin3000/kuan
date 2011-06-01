# -*- coding: utf-8 -*-
require 'spec_helper'

describe Feed do
  describe "Importing a feed" do
    before :each do
      @user = Factory.create(:user_unique)
      @blog = @user.create_primary_blog!
    end

    after :each do
      Blog.delete_all
      Feed.delete_all
    end

    it "should record an importing relationship" do
      feed_uri = "http://9tonight.blogbus.com/index.rdf"
      type = :pics
      @blog.import!(feed_uri, type, @user).should be_true
      @blog.reload
      @blog.import_feeds.first.as_type.should == type
      @blog.import_feeds.first.feed.uri.should == feed_uri
      @blog.import_feeds.first.feed.imported_count.should == 1
      @blog.import_feeds.first.feed.title.should == "Silence"
      @blog.import_feeds.first.feed.fetched_at.should == Time.at(0)
      @blog.import_feeds.first.author.should == @user
    end

    it "should record two importing relationship" do
      feed_uri = "http://blog.sina.com.cn/twocold"
      type = :text
      @blog.import!(feed_uri, type, @user).should be_true
      @blog.reload
      @blog.import_feeds.first.as_type.should == type
      @blog.import_feeds.first.feed.uri.should == "http://blog.sina.com.cn/rss/1191258123.xml"
      @blog.import_feeds.first.feed.imported_count.should == 1
      @blog.import_feeds.first.feed.title.should == "韩寒"
      blog2 = Factory.build :blog_unique
      @user.follow! blog2, "founder"
      blog2.import!(feed_uri, type, @user).should be_true
      blog2.import_feeds.first.feed.should == @blog.import_feeds.first.feed
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
      @blog.import!(uri, :pics, @user).should be_false
      @blog.errors.should be_has_key(:import_feed_uri)
    end 

    it "should not accept same import feed" do
      feed_uri = "http://9tonight.blogbus.com/index.rdf"
      @blog.import!(feed_uri, :pics, @user).should be_true
      @blog.import!(feed_uri, :text, @user).should be_false
      @blog.errors.should be_has_key(:import_feed_uri)
    end

    it "should not accept >3 import feeds" do
      # crazy slow
      # @blog.import!("http://9tonight.blogbus.com", :pics, @user).should be_true
      # @blog.import!("moehuaji.diandian.com", :pics, @user).should be_true
      # @blog.import!("http://hi.baidu.com/%C2%BD%BE%B0%EC%AA", :pics, @user).should be_true
      # @blog.import!("http://blog.sina.com.cn/twocold", :pics, @user).should be_false
      # @blog.errors.should be_has_key(:import_feed_uri)
    end
  end

  describe "Canceling a importing feed" do
    before :each do
      @user = Factory.build(:user_unique)
      @blog = @user.create_primary_blog!
    end

    after :each do
      Blog.delete_all
      Feed.delete_all
    end

    it "should delete an import feed" do
      @blog.import!("http://9tonight.blogbus.com", :pics, @user).should be_true
      @blog.import!("moehuaji.diandian.com", :pics, @user).should be_true
      feed_delete = @blog.import_feeds.first.feed
      feed_exist = @blog.import_feeds.second.feed
      @blog.cancel_import! feed_delete
      @blog.reload
      @blog.import_feeds.count.should == 1
      @blog.import_feeds.first.feed.should == feed_exist
    end
  end
end
