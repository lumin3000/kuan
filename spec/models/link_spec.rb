require 'spec_helper'

describe Link do
  subject { Link.new url: "http://www.g.cn", title: "Google" }
  it "should have url and title field" do
    subject.url.should_not be_nil
    subject.title.should_not be_nil
  end
end
