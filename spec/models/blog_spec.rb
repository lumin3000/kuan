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
      @blog.icon = Image.create!
      @blog.save!
      @blog.reload
      @blog.icon.url_for(:large).should_not == "/images/default_icon_large.gif"
    end
  end

  describe "title validation" do
    it "should reject too long title" do
      @blog.title = "a"*41
      @blog.should_not be_valid
    end
  end

  describe "canjoin validation" do
    it "should not be joined for primary blog" do
      user = Factory :user
      blog = user.create_primary_blog!
      blog.canjoin = true
      blog.should_not be_valid
      user.delete
    end
  end

  describe "find_by_uri" do
    it "should find the correct blog" do
      Blog.find_by_uri!(@blog.uri).should == @blog
    end
  end

  describe "public blogs" do
    before :each do
      Blog.delete_all
    end

    it "should show public blogs" do
      @blog = Factory.build(:blog_unique)
      @blog2 = Factory.build(:blog_unique)
      @blog.save
      @blog2.save
      Blog.public.length.should == 2
      Blog.public.should include @blog
      Blog.public.should include @blog2
    end

    it "should not show private blogs" do
      @blog = Factory.build(:blog_unique)
      @blog_private = Factory.build(:blog_unique, :private => true)
      @blog.save
      @blog_private.save
      Blog.public.length.should == 1
      Blog.public.should include @blog
      Blog.public.should_not include @blog_private
    end
    it "should handle old data private is nil" do
      @blog = Factory.build(:blog_unique)
      @blog_old = Factory.build(:blog_unique, :private => nil)
      @blog.save
      @blog_old.save
      Blog.public.length.should == 2
      Blog.public.should include @blog
      Blog.public.should include @blog_old
    end
  end
end
