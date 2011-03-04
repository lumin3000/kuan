# -*- coding: utf-8 -*-
require 'spec_helper'

describe Blog do

  before :each do
    @blog = Blog.create(:uri=>"blog-uri", :title=>"blog title")
  end

  after :each do
    Blog.delete_all
  end 

  describe "uri validation" do
    it "should reject unvalid uri" do
      uris = ["中文是不可以",
              'sho',
              'Silen',
              'a'*31,
              "_forbid",
              ""]
      uris.each do |u|
        @blog.uri = u
        @blog.should_not be_valid
      end
    end

    it "should reject duplicate uri" do
      blog_dup = Blog.new(:title => "whatever",
                          :uri => @blog.uri)
      blog_dup.should_not be_valid
      blog_dup.uri.upcase!
      blog_dup.should_not be_valid
    end

    it "should accept valid uri" do
      @blog.uri = "validuri"
      @blog.should be_valid
      @blog.uri = "valid-uri"
      @blog.should be_valid
    end 
  end

  describe "default icon" do
    it "should use the default icon" do
      @blog.icon.url_for(:large).should == "/images/default_icon_large.gif"
    end

    it "should use the set icon" do
      @blog.icon = Image.new
      @blog.icon.url_for(:large).should_not == "/images/default_icon_large.gif"
    end
  end

  describe "title validation" do
    it "should reject too long title" do
      @blog.title = "a"*41
      @blog.should_not be_valid
    end
  end

  describe "find_by_uri" do
    it "should find the correct blog" do
      Blog.find_by_uri!(@blog.uri).should == @blog
    end
  end

  describe "Following logic" do
    describe "Given a blog which is primary" do
      before :all do
        @user = Factory :user, :name => "peanucock", :email => Factory.next(:email)
        @primary_blog = @user.create_primary_blog!
        @guest = Factory :user, :name => "passenger", :email => Factory.next(:email)
      end
    end
  end

end
