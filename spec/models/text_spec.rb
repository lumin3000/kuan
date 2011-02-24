require 'spec_helper'

describe Text do
  before :all do
    @user = Factory.build :user
    @blog = Factory.build :blog
  end
  

  describe "Given a new blog post" do
    before :all do
      @text = Text.new({
        content: "not very long", title: "hi there",
        blog: @blog,
        author: @user,
      })
    end

    it "should have content" do
      @text.content.should_not be_nil
      @text.should be_valid
    end
  end

  describe "Given an empty blog post" do
    subject { Text.new content: "", title: "I'm empty!"}

    it "should not validate" do
      subject.should_not be_valid
    end
  end
end
