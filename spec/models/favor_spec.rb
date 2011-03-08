require 'spec_helper'

describe "Favor" do

  before :each do
    @user = Factory :user_unique
    @author = Factory :user_unique
    @blog = @author.create_primary_blog!
    @post = Text.new(:content => "For favor")
    @post.author = @author
    @post.blog = @blog
    @post.save
  end

  describe "user add favors" do
    it "should add the favor" do
      @user.add_favor_post! @post
      @user.reload
      @user.favor_posts.count.should == 1
      @user.favor_posts.first.should == @post
      @post.should be_favored_by @user
      @post.reload
      @post.favor_count.should == 1
    end

    it "should not add the same favor" do
      @user.add_favor_post! @post
      @user.add_favor_post! @post
      @user.reload
      @user.favor_posts.count.should == 1
      @post.reload
      @post.favor_count.should == 1
    end 

    it "should not add nil post" do
      @user.add_favor_post! nil
      @user.reload
      @user.favor_posts.should be_empty
    end

    it "should limit favors length" do
      #1000 favors run too slow, waitting for mocks
    end
  end

  describe "user delete favors" do
    before :each do
      @user.add_favor_post! @post
    end

    it "should delete the favor" do
      @user.del_favor_post! @post
      @user.favor_posts.count.should == 0
      @post.should_not be_favored_by @user
      @post.favor_count.should == 0
    end
  end
 
end
