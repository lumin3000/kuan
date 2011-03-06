require 'spec_helper'

describe Comment do
  before :each do
    @comment = Factory :comment
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
    before :each do
      @blog = Factory.create(:blog_unique)
      @user = Factory.create(:user_unique)
      @user.follow! @blog, "lord"
      @comment_author = Factory.create(:user_unique)
      @post = Factory.build(:text)
      @post.author = @user
      @post.blog = @blog
      @post.save!
    end
      
    it "should notice post author" do

      length = @user.comments_notices.unreads.count
      @new_comment = Comment.new
      @new_comment.post = @post
      @new_comment.author = @comment_author
      @new_comment.post.should_not be_nil
      @new_comment.content = "just content"
      @post.watchers.should be_include(@user)
      @new_comment.save.should be_true
      @user.comments_notices.unreads.count.should == length + 1
    end
  end
end
