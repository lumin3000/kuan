require 'spec_helper'

describe "Message" do

  before :each do
    @user = Factory :user_unique
    @blog = Factory :blog_unique
    @blog_primary = @user.create_primary_blog!
    @user.follow! @blog, "founder"
    @sender = Factory(:user_unique, :email => Factory.next(:email))
    @blog.canjoin = true
    @blog.save!
  end

  after :each do
    User.delete_all
    Blog.delete_all 
  end

  describe "send apply to join blog message"do

    describe "failed apply" do
      it "should not send message for blog can't be joined" do
        @blog.canjoin = false
        @blog.applied(@sender).should be_false
      end
    end

    describe "successed apply" do
      before :each do
        @blog.applied(@sender)
        @user.reload
        @message = @user.messages.first
      end

      it "should send message" do
        @message.should_not be_nil
        @message.sender.should == @sender
        @message.blog.should == @blog
        @message.type.should == "join"
      end

      it "should reject the same message" do
        @blog.applied(@sender)
        @user.reload 
        @user.messages.count.should == 1
      end 

      describe "messages length limit" do
        before :each do
          99.times do
            @blog.applied(Factory(:user, :email => Factory.next(:email)))
          end
        end

        it "should not save 101th message" do
          sender = Factory(:user, :email => Factory.next(:email))
          @blog.applied(sender)
          @user.reload
          @user.messages.count.should == 100
        end

        it "should remove the first message" do
          sender = Factory(:user, :email => Factory.next(:email))
          @blog.applied(sender)
          @user.reload
          @user.messages.should_not include @message
        end
      end
    end

    describe "multi founder apply" do
      it "all founders should receive message" do
        @blog.reload
        founder_second = Factory(:user, :email => Factory.next(:email))
        founder_second.follow! @blog, "founder"
        founder_third = Factory(:user, :email => Factory.next(:email))
        founder_third.follow! @blog, "founder"
        @blog.applied @sender
        @user.reload
        @user.messages.first.should_not be_blank
        @user.messages.first.sender.should == @sender
        founder_second.reload
        founder_second.messages.first.sender.should == @sender
        founder_third.reload
        founder_third.messages.first.sender.should == @sender
      end
    end
  end

  describe "get messages list" do
    it "should order in desc" do
      @blog.applied @sender
      @user.reload
      next_sender = Factory(:user, :email => Factory.next(:email))
      @blog.applied next_sender
      @user.reload
      @user.messages.reverse.first.sender.should == next_sender
      @user.messages.reverse.last.sender.should == @sender
    end
  end

  describe "read messages " do
    before :each do
      @blog.applied @sender
      @user.reload
      @first_message = @user.messages.first
      @blog.applied Factory(:user, :email => Factory.next(:email))
      @user.reload
      @second_message = @user.messages.second

    end

    it "should change unread status" do
      @first_message.read!
      @user.reload
      @user.messages.first.should_not be_unread
    end

    it "should give the correct unread counts" do
      @first_message.read!
      @user.reload
      @user.messages.unreads.count.should == 1
      @user.messages.unreads.first.should == @second_message
    end

    it "should read all messages" do
      @user.read_all_messages!
      @user.reload
      @user.messages.unreads.count.should == 0
      @user.messages.first.should_not be_unread
      @user.messages.second.should_not be_unread
    end
  end

  describe "ignore and doing message" do
    before :each do
      @blog.applied @sender
      @user.reload
      @first_message = @user.messages.first
    end

    it "should ignore message" do
      @first_message.ignore!
      @user.reload
      @user.messages.find(@first_message.id).should be_ignored
    end

    it "should doing message" do
      @first_message.doing!
      @user.reload
      @user.messages.find(@first_message.id).should be_done
      @sender.reload
      @blog.should be_edited @sender
    end

  end

  describe "send apply to join blog message"do
    it "should send feed" do
      @blog.applied(@sender)
      @user.reload
      @message = @user.messages.first
      @message_feed = @message.feed!
      @sender.reload
      @sender.messages.should include @message_feed
      @message_feed.should_not be_nil
      @message_feed.sender.should == @user
      @message_feed.blog.should == @blog
      @message_feed.type.should == "join_feed"
    end
  end

  describe "follow a blog" do
    it "should send messages to founders" do
      @blog_member = Factory :blog_unique
      @user.follow! @blog_member, "founder"
      @blog_member.canjoin = true
      @blog_member.save!
      @user.reload
      length = @user.messages.length
      @new_user = Factory :user_unique
      @new_user.follow! @blog_member
      @user.reload
      @user.messages.length.should == length + 1
    end
    it "should send messages to lord" do
      length = @user.messages.length
      @new_user = Factory :user_unique
      @new_user.follow! @blog_primary
      @user.reload
      @user.messages.length.should == length + 1
    end
  end

end
