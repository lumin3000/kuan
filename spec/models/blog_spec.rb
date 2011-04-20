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
              'a'*256,
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
      @blog.icon.url_for(:large).should == "/images/default_icon_180.jpg"
    end

    it "should use the set icon" do
      @blog.icon = Image.create!
      @blog.save!
      @blog.reload
      @blog.icon.url_for(:large).should_not == "/images/default_icon_180.jpg"
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

  describe "list latest blogs" do
    before :each do
      Blog.delete_all
    end
    describe "only show public" do
      it "should show public blogs" do
        @blog = Factory.build(:blog_unique, :posted_at => Time.now)
        @blog2 = Factory.build(:blog_unique, :posted_at => Time.now)
        @blog.save
        @blog2.save
        Blog.latest.length.should == 2
        Blog.latest.should include @blog
        Blog.latest.should include @blog2
      end
      it "should not show private blogs" do
        @blog = Factory.build(:blog_unique, :posted_at => Time.now)
        @blog_private = Factory.build(:blog_unique, :private => true, :posted_at => Time.now)
        @blog.save
        @blog_private.save
        Blog.latest.length.should == 1
        Blog.latest.should include @blog
        Blog.latest.should_not include @blog_private
      end
      it "should handle old data private is nil" do
        @blog = Factory.build(:blog_unique, :posted_at => Time.now)
        @blog_old = Factory.build(:blog_unique, :private => nil, :posted_at => Time.now)
        @blog.save
        @blog_old.save
        Blog.latest.length.should == 2
        Blog.latest.should include @blog
        Blog.latest.should include @blog_old
      end
    end

    describe "order" do
      before :each do
        Post.delete_all
        Blog.delete_all
   
        @blog = Factory.build(:blog_unique)
        @blog_new = Factory.build(:blog_unique)
        @user = Factory.build(:user_unique)
        @user.follow! @blog, "lord"
        @user.follow! @blog_new, "lord"
        @post = Factory.build(:text)
        @user.save
        @blog.save
        @blog_new.save
        @post.author = @user
        @post.blog = @blog
        @post.created_at = 1.hour.ago
        @post.save!
        @blog.reload
      end
      it "should order desc" do
        @post_new = Factory.build(:text)
        @post_new.author = @user
        @post_new.blog = @blog_new
        @post_new.save!
        @blog_new.reload
   
        @latest = Blog.latest
        @latest.first.should == @blog_new
        @latest.last.should == @blog
      end
    end
  end
  describe "get lord" do
    it "should get lord" do
      @user = Factory.build(:user_unique)
      @user.save
      @blog = @user.create_primary_blog!
      @user.reload
      @blog.lord.should == @user
    end
  end
  describe "update blog privacy" do
    before :each do
      @user = Factory.build(:user_unique)
      @user.save!
      @blog = @user.create_primary_blog!
      @post = Factory.build(:text)
      @post.author = @user
      @post.blog = @blog
    end
    it "should set to private when blog update to private" do
      @post.save!
      @post.private.should be_false
      @blog.private = true
      @blog.save!
      @post.reload
      @post.private.should be_true
    end
    it "should set to public when blog update to public" do
      @blog.private = true
      @blog.save!
      @post.save!
      @post.private.should be_true
      @blog.private = false
      @blog.save!
      @post.reload
      @post.private.should be_false
    end
    it "should set all post" do
      @post.save!
      @post2 = Factory.build(:text)
      @post2.author = @user
      @post2.blog = @blog
      @post2.save!
      @post.private.should be_false
      @post2.private.should be_false
      @blog.private = true
      @blog.save!
      @post.reload
      @post2.reload
      @post.private.should be_true
      @post2.private.should be_true
    end
  end
end
