require 'spec_helper'

describe "Following" do

  before :each do
    @user = Factory :user
    @blog = Factory :blog
    @following = Factory :following, :blog => @blog
    @user.follow @following
  end

  after :each do
    User.delete_all
    Blog.delete_all
  end

  describe "validation" do
    it "should reject error auths" do
      @following.auth = "other"
      @following.should_not be_valid
    end

    it "should accept correct auths" do
      %w[follower member founder].each do |a|
        @following.auth = a
        @following.should be_valid
      end
    end
  end

  describe "user followings" do

    it "should be in user followings" do
      @user.should respond_to :followings
    end

    it "should have blog" do
      @user.followings.first.blog.should == @blog
    end

    it "should have user" do
      @user.followings.first.user.should == @user
    end

    it "should update the same blog following" do
      @following.auth = "founder"
      lambda do
        @user.follow @following
      end.should_not change(@user.followings, :count)
      @user.followings.first.auth.should == "founder"
    end
 
    it "should add the different blog following" do
      blog_n = Factory(:blog, :uri =>Factory.next(:uri))
      lambda do
        @user.follow Following.new(:auth=>"member", :blog=>blog_n)
      end.should change(@user.followings, :count).by(1)
    end

  end

  describe "user blogs" do
    it "should order the blogs by auth" do
      @user.followings = []
      bm = Factory(:blog, :uri =>Factory.next(:uri))
      @user.follow Following.new(:auth=>"member", :blog=>bm)
      bl = Factory(:blog, :uri =>Factory.next(:uri))
      @user.follow Following.new(:auth=>"lord",
                                 :blog=>bl)
      bf = Factory(:blog, :uri =>Factory.next(:uri))
      @user.follow Following.new(:auth=>"founder", :blog=>bf)
      @user.blogs.first.should == bl
      @user.blogs.second.should == bf
      @user.blogs.third.should == bm
    end
  end

end
