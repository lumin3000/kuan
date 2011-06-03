require 'spec_helper'

describe Comment do
  before :each do
    @blog = Factory.create(:blog_unique)
    @user = Factory.create(:user_unique)
    @user.follow! @blog, "lord"
    @comment_author = Factory.create(:user_unique)
    @post = Factory.build(:text)
    @post.author = @user
    @post.blog = @blog
    @post.save!
    @comment = Comment.new(:content => "comm")
    @old_comment_author = Factory.create(:user_unique)
    @comment.author = @old_comment_author
    @post.comments << @comment
  end

  describe "content validations" do
    it "should not blank" do
      @comment.content = nil
      @comment.should_not be_valid
    end
    it "should not empty" do
      @comment.content = ""
      @comment.should_not be_valid
    end
  end

  describe "notice watchers when user comment a post" do
    it "should notice post author" do
      @new_post = Factory.build(:text)
      @new_post.author = @user
      @new_post.blog = @blog
      @new_comment = Comment.new
      @new_comment.author = @comment_author
      @new_comment.content = "just content"
      @new_post.comments << @new_comment
      @new_comment.post.should_not be_nil
      @post.watchers.should be_include(@user)
      @user.reload
      @user.comments_notices.unreads.count.should == 1
    end
  end

  describe "mute post" do
    it "should mute/unmute a post" do
      post = Factory.build(:text)
      post.author = @user
      post.blog = @blog
      post.save
      
      @user.mute! post
      @user.reload
      comment = Comment.new
      comment.author = @comment_author
      comment.content = "just content"
      post.comments << comment 
      post.should be_muted_by @user
      post.watchers.should_not be_include(@user)
      @user.comments_notices.unreads.count.should == 1
 
      @user.unmute! post
      @user.reload
      post.watchers.should be_include(@user)
      new_comment = Comment.new
      new_comment.author = @comment_author
      new_comment.content = "just content2"
      post.comments << new_comment
      @user.comments_notices.unreads.count.should == 2
      post.should_not be_muted_by @user
    end
  end

  describe "manage comment" do
    it "should be manageable" do
      @comment.manageable_by?(@user).should be_true
    end
    it "should be manageable" do
      @comment.manageable_by?(@old_comment_author).should be_true
    end
    it "should be unmanageable" do
      @comment.manageable_by?(@comment_author).should be_false
    end
  end
end
