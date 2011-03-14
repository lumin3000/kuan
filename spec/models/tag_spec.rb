# -*- coding: utf-8 -*-
require 'spec_helper'

describe Tag, " for posts" do
  before :each do
    @tag_first = "tag-first"
    @tag_second = "标签"
    @blog = Factory :blog_unique
    @user = Factory :user_unique
    @user.follow! @blog, "lord"
    @user.reload
    @post = Text.create!(:content => "Test for tags",
                         :author => @user,
                         :blog => @blog,
                         :tags => [@tag_first, @tag_second])
    @post.reload
  end

  after :each do
    Post.delete_all
  end

  it "should have the correct tags" do
    @post.tags.count.should == 2
    @post.tags.first.should == @tag_first
    @post.tags.last.should == @tag_second
  end

  it "should reject the invalid tags" do
    tag_invalid = "a,b"
    @post.tags = [tag_invalid]
    @post.tags.should be_empty
  end

  it "should not add the same tag" do
    @post.tags = [@tag_first, @tag_second, @tag_second.dup]
    @post.tags.count.should == 2
  end

  it "should accept the tags string join by space" do
    @post.tags = [@tag_first, @tag_second].join ','
    @post.tags.first.should == @tag_first
    @post.tags.last.should == @tag_second
  end

  it "should accept the tags join by \n" do
    @post.tags = " " + ([@tag_first, @tag_second].join "\n") + " "
    @post.tags.first.should == @tag_first
    @post.tags.last.should == @tag_second
  end

  it "should get tagged posts" do
    post_next = Text.create!(:content => "Test next for tags",
                             :author => @user,
                             :blog => @blog,
                             :tags => @tag_first)
    posts = Post.tagged @tag_first
    posts.count.should == 2
  end
end

describe Tag, " for blogs" do
  before :each do
    @tag = "tag-first"
    @blog = Blog.create!(:uri => "testtags",
                         :title => "test for tags",
                         :tag => @tag)
  end

  after :each do
    Blog.delete_all
  end

  it "should have the correct tag" do
    @blog.tag.should == @tag
  end

  it "should reject the invalid tag" do
    @blog.tag = "a,b"
    @blog.should_not be_valid
    @blog.tag = " "
    @blog.should be_valid
    @blog.tag.should be_nil
    @blog.tag = ""
    @blog.should be_valid
    @blog.tag.should be_nil 
  end

  it "should get tagged blogs" do
    blog_next = Blog.create!(:uri => "testtagsnext",
                             :title => "test for tags next",
                             :tag => @tag)
    Blog.tagged(@tag).count.should == 2
  end
end
