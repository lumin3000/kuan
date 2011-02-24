require 'spec_helper'

describe ApplicationHelper do
  before :each do
  end

  it "should render post" do
    for po in Post.subclasses
      # assign(:p, Post.new)
      post = Factory po.name.downcase.to_sym
      reg = "<div.*"+(post[:content].nil? ? "" : post.content)+".*</div>"
      helper.render_post(post).should =~ Regexp.new(reg, Regexp::MULTILINE)
    end
  end
end
