require 'spec_helper'

describe Link do
  subject { Link.new url: "http://www.g.cn", title: "Google" }
  it "should have url and title field" do
    subject.url.should_not be_nil
    subject.title.should_not be_nil
  end

  it "should receive this bad url" do
    bad = Link.new(:url => "1234", :title => "1234")
    author = Factory :user_unique
    bad.author = author
    bad.blog = author.create_primary_blog!
    bad.should be_valid
    bad.save
  end
end
