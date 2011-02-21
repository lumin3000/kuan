require 'spec_helper'

describe Blog do
  describe "Given a new blog post" do
    subject { Blog.new content: "not very long", title: "hi there"}

    it "should have content" do
      subject.content.should_not be_nil
      should be_valid
    end
  end

  describe "Given an empty blog post" do
    subject { Blog.new content: "", title: "I'm empty!"}

    it "should not validate" do
      subject.should_not be_valid
    end
  end
end
