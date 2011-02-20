require 'spec_helper'

describe Blog do
  describe "Given a new blog post" do
    subject { Blog.new content: "not very long", title: "hi there"}

    it "should have content and title" do
      subject.content.should_not be_nil
      subject.title.should_not be_nil
    end
  end
end
