require 'spec_helper'

describe ApplicationHelper do
  before :each do
  end

  it "should render post" do
    for po in Post.subclasses
      # assign(:p, Post.new)
      post = Factory.build po.name.downcase.to_sym
      unless post[:content].nil?
        helper.render_post(post).should be_include(post.content)
      end
    end
  end
end
