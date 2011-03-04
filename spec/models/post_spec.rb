require 'spec_helper'

describe Post do
  #pending "Abstract class, dunno what to do"

  describe "notice watchers when usre comment a post" do
    before :each do
      @blog = Factory.build(:blog_unique)
      @following = Factory.build(:following_lord, :blog => @blog)
      @user = Factory.build(:user_unique, :followings => [@following])
      @comment_author = Factory.build(:user_unique)
      @comment_user = Factory.build(:user_unique)
      @post = Post.new
      @post.author = @user
    end
      
    it "should notice post author" do
      length = @user.unread_comments_notices.length
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @user.unread_comments_notices.length.should == length + 1
    end

    it "should notice other comment user" do
      @comment_old = Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_user.unread_comments_notices.length
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_user.unread_comments_notices.length.should == length + 1
    end

    it "should not notice self" do
      @comment_old = Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_author.unread_comments_notices.length
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_author.unread_comments_notices.length.should == length
    end

    it "should not notice same user twice" do
      Factory.build(:comment, :post => @post, :author => @comment_user)
      Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_user.unread_comments_notices.length
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_user.unread_comments_notices.length.should == length + 1
    end

    it "should list all watchers" do
      @comment = Comment.new
      @comment.post = @post
      @comment.author = @comment_user
      @comment.save
      watchers = @post.watchers
      watchers.should be_include(@post.author)
      watchers.should be_include(@comment_user)
    end
  end
end
