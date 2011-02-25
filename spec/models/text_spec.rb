require 'spec_helper'

describe Text do
  before :all do
    @blog = Factory :blog, :uri => Factory.next(:uri)
    @owage = Factory :following, {
      auth: "founder",
      blog: @blog,
    }
    @user = Factory :user, :followings => [@owage], :email => Factory.next(:email)

    @params = {
      blog_id: @blog.id.to_s,
      author_id: @user.id.to_s,
    }
  end

  describe "Given a new blog post" do
    before :all do
      @text = Text.new(@params.dup.update({
        content: "not very long", title: "hi there",
      }))
    end

    it "should be valid" do
      @text.should be_valid
    end
  end

  describe "Given an empty blog post" do
    subject do
      Text.new @params.update({
        content: "",
        title: "I'm empty!",
      })
    end

    it "should not validate" do
      should_not be_valid
    end
  end

  describe "Given a post without author" do
    it "should not validate" do
      @text = Text.new({
        content: "whatever",
        blog_id: @blog.id,
      })
      @text.should_not be_valid
    end
  end

  describe "Given a post without target blog" do
    it "should not validate" do
      @text = Text.new({
        content: "whatever",
        author_id: @user.id,
      })
    end
  end
  
end
