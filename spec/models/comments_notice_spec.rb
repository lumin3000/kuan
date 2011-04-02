require 'spec_helper'

describe CommentsNotice do
  before :each do
    @blog = Factory.build(:blog_unique)
    @user = Factory.build(:user_unique)
    @user.follow! @blog, "lord"
    @post = Factory.build(:text)
    @user.save
    @blog.save
    @post.author = @user
    @post.blog = @blog
    @post.save

    @post_new = Factory.build(:text)
    @post_new.author = @user
    @post_new.blog = @blog
    @post_new.save

    @post_old = Factory.build(:text)
    @post_old.author = @user
    @post_old.blog = @blog
    @post_old.save

    @comments_notice = CommentsNotice.new(:post => @post)
    @read_comments_notice = CommentsNotice.new(:unread => false, :post => @post)
    @old_comments_notice = CommentsNotice.new(:post => @post_old, :created_at => 1.hour.ago)
  end

  describe "comments_notiecs scope" do
    it "should provide unread" do
      @user.comments_notices << @comments_notice
      @user.comments_notices << @read_comments_notice
      @user.comments_notices.unreads.should be_include @comments_notice
      @user.comments_notices.unreads.should_not be_include @read_comments_notice
    end

    it "should provide unread count" do
      @user.comments_notices.unreads.count.should == 0
      @user.comments_notices << @comments_notice
      @user.comments_notices << @read_comments_notice
      @user.comments_notices.unreads.count.should == 1
    end
  end

  describe "given comments notices list" do
    before :each do
      
      @user.comments_notices << @old_comments_notice
      @user.comments_notices << @comments_notice

      @user.save
      @user.reload
      @pagination = {
        :page => 1,
        :order => "created_at DESC",
        :per_page => 999,
      }
    end

    it "should order in desc" do
      @user.comments_notices.first.post.should == @post_old
      tmp = @user.comments_notices_list(@pagination)
      tmp.first.post.should == @post
    end

    it "should list unread" do
      @user.comments_notices.first.unread = false
      tmp = @user.unread_comments_notices_list(@pagination)
      tmp.length.should == 1
      tmp.first.post.should == @post
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

  describe "read notice" do
    it "should set unread = false" do
      @post = Post.new
      @new_comments_notice = CommentsNotice.new(:post => @post)

      @user.comments_notices = [ @comments_notice, 
                                @read_comments_notice,
                                @new_comments_notice ]
      @user.reload
      length = @user.comments_notices.unreads.count
      @user.comments_notices.last.read!
      @user.reload
      @user.comments_notices.unreads.count.should == length - 1
    end
  end

  describe "set all unread comments notices read" do
    it "should set user's all notices unread = false" do
      @user.comments_notices = [@comments_notice, 
                                @comments_notice, 
                                @read_comments_notice,
                                @comments_notice]
      @user.reload
      @user.comments_notices.unreads.count.should > 0
      @user.read_all_comments_notices!
      @user.reload
      @user.comments_notices.unreads.count.should == 0
    end
  end

  describe "limit user comments notices in database" do
    before :each do
      @post_first = Factory.build(:text)
      @user.insert_unread_comments_notices!(@post_first)
      @user.reload
      @length1 = @user.comments_notices.length
      98.times do |i|
        @user.insert_unread_comments_notices!(Factory.build(:text))
      end
      @user.reload
      @length99 = @user.comments_notices.length
      @user.insert_unread_comments_notices!(Factory.build(:text))
      @user.reload
      @length100 = @user.comments_notices.length
      @user.insert_unread_comments_notices!(@post_new)
      @user.reload
      @length_more = @user.comments_notices.length
    end
    
    it "should not save more than 100 comments notices" do
      @length1.should == 1
      @length99.should == 99
      @length100.should == 100
      @length_more.should == 100
    end

    it "should remove first comments notice" do
      @user.comments_notices.first.post.should_not == @post_first
    end

    it "should include last comments notice" do
      @user.comments_notices.last.post.should == @post_new
    end
  end

  describe "bind with post" do
    it "related comments notices should not exist after post deleted" do
      @user.insert_unread_comments_notices!(@post)
      @user.insert_unread_comments_notices!(@post_new)

      @user.reload
      @user.comments_notices.length.should == 2
      @post.destroy
      @user.reload
      @user.comments_notices.length.should == 1

    end
  end
end
