require 'spec_helper'

describe Tweet do
  describe "Given a new tweet with content `fooo`" do
    subject { Tweet.new content: "fooo" }

    it "should have content `fooo`" do
      subject.content.should == "fooo"
    end
  end
end
