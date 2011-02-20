require 'spec_helper'

describe Tweet do
  describe "Given a new tweet with content `fooo`" do
    subject { Tweet.new content: "fooo" }

    it "should have content `fooo`" do
      subject.content.should == "fooo"
    end

    it "could be fetched by parent class after saved" do
      subject.save!
      posts = Post.find :all
      posts.to_ary.should include(subject)
      subject.should be_kind_of Mongoid::Timestamps
    end
  end
end
