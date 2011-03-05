require 'spec_helper'

describe "Message" do

  before :each do
    @user = Factory :user
    @blog = Factory :blog
    @blog_primary = @user.create_primary_blog!
    @user.follow! @blog, "founder"
    @sender = Factory(:user, :email => Factory.next(:email))
  end

  after :each do
    User.delete_all
    Blog.delete_all
  end
  
  describe "send apply to join blog message"do

    describe "failed apply" do
      it "should not send message for blog can't be joined" do
        @blog.applied(@sender).should be_false
      end
    end

    describe "successed apply" do
      it "should send message" do
        @blog.canjoin = true 
        @blog.applied(@sender).should be_true
        @user.reload  
        message = @user.messages.first
        message.should_not be_nil
        message.sender.should == @sender
        message.blog.should == @blog
        message.type.should == "join"
      end
    end

  end
  
end
