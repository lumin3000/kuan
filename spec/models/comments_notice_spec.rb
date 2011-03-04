require 'spec_helper'

describe CommentsNotice do
  before :each do
    @blog = Factory.build(:blog_unique)
    @following = Factory.build(:following_lord, :blog => @blog)
    @user = Factory.build(:user_unique, :followings => [@following] )

    # @post = Factory.build(:post, :author => @user, :blog => @blog)
    @post = Post.new

    @comments_notice = Factory.build(:comments_notice, :post => @post)
    @read_comments_notice = Factory.build(:read_comments_notice, :post => @post)
    # @comment.post = @post
  end


  describe "unread comments notices list" do
    it "should get unread comments notices" do
      @user.comments_notices = [@comments_notice, @read_comments_notice]
      @user.unread_comments_notices.length.should == 1
    end
  end

  describe "count unread comments notices" do
    it "should get unread comments notices count" do
      @user.comments_notices = [@comments_notice, @read_comments_notice]
      @user.count_unread_comments_notices.should == 1
    end
  end

  describe "insert comments notices" do
    it "should insert new comments notice" do
      length = @user.comments_notices.length
      @user.insert_unread_comments_notices!(@post)
      @user.comments_notices.length.should == length + 1
    end

    it "should remove previous comments notice" do
      @user.insert_unread_comments_notices!(@post)
      comments_notices_id = @user.comments_notices.last.id
      length = @user.comments_notices.length

      @user.insert_unread_comments_notices!(@post)
      new_comments_notices_id = @user.comments_notices.last.id

      @user.comments_notices.length.should == length
      new_comments_notices_id.should_not == comments_notices_id
    end
  end

  describe "mark as one notice as read" do
    it "should set user's one notice unread = false" do
      @post = Post.new
      @new_comments_notice = Factory.build(:comments_notice, :post => @post)

      @user.comments_notices = [ @comments_notice, 
                                @read_comments_notice,
                                @new_comments_notice ]

      length = @user.unread_comments_notices.length
      @user.read_one_comments_notice! @post
      @user.unread_comments_notices.length.should == length - 1
    end
  end

  describe "set all unread comments notices read" do
    it "should set user's all notices unread = false" do
      @user.comments_notices = [@comments_notice, 
                                @comments_notice, 
                                @read_comments_notice,
                                @comments_notice]
      @user.unread_comments_notices.length.should > 0
      @user.read_all_comments_notices!
      @user.unread_comments_notices.length.should == 0
    end
  end

  describe "comments post" do
    before :each do
    end

    it "should notice post auther" do
      @comment = Factory.build :comment
    end

    it "should notice other users who commented before" do
    end

    it "should not notice self" do
    end

    it "should not notice more than once" do
    end
  end
end
