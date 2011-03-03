require 'spec_helper'

describe CommentNotice do
  before :each do
    @post = Factory.build :text
    @user = Factory.build :user2
  end

  after :each do
  end

  describe "comment post" do
    before :each do
    end

    it "should notice post auther" do
    end

    it "should notice other users who commented before" do
    end

    it "should not notice self" do
    end

    it "should not notice more than once" do
    end
  end

  describe "read comment notices" do
    it "should set user's all notices unread = false" do
    end
  end
    
end
