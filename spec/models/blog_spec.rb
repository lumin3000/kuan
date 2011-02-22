# -*- coding: utf-8 -*-
require 'spec_helper'

describe Blog do

  before(:each) do
    @blog = Factory :blog
  end

  after(:each) do
    Blog.delete_all
  end 


  describe "uri validation" do
    it "should reject unvalid uri" do
      uris = ["中文是不可以",
              'sho',
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
    end 

  end

  describe "title validation" do
    it "should reject too long title" do
      @blog.title = "a"*41
      @blog.should_not be_valid
    end
  end

end
