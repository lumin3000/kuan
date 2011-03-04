require 'spec_helper'

describe Moving do

  before :each do
    @user = Factory :user
  end

  after :each do
    User.delete_all
    Blog.delete_all
    Moving.delete_all
  end

  describe "moving validation" do

    before :each do
      @blog = Factory :blog
      @user.follow! @blog, "founder"
    end
    
    it "should accepted own blog" do 
      %w[kuantu1 lintb lintb.kuantu.com http://lintb.kuantu.com].each do |from|
        Moving.new(:from_uri => from, :to_uri => @blog.uri, :user => @user).should be_valid
      end
    end

    it "should accepted and create blog" do
      m = Moving.new(:from_uri => "http://deviantart13.kuantu.com", :to_uri => "deviant", :user => @user)
      m.save.should be_true
      m.reload  
      m.to_uri.should == "deviant"
      m.from_uri.should == "http://deviantart13.kuantu.com"
      m.user.should == @user
      blog = Blog.where(:uri => "deviant").first
      blog.should_not be_nil
      blog.should be_customed @user
    end
 
    it "should rejected" do 
      [" " "sureinvalid" "http://ture.kuantu.com"].each do |from|
        m = Moving.new(:from_uri => from, :to_uri => @blog.uri, :user => @user)
        m.should_not be_from_uri_valid
      end

      @user.unfollow! @blog
      @user.reload
      m = Moving.new(:from_uri => "lintb", :to_uri => @blog.uri, :user => @user)
      m.save.should be_false
    end
  end

end
