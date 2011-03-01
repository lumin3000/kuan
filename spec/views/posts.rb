# -*- coding: utf-8 -*-
require 'spec_helper'

describe "posts/new.html.haml" do
  before :all do
    blogs = (1..10).map do |n|
      Factory.build :blog
    end
    assign(:target_blogs, blogs)
    assign(:user, Factory.build(:user))
  end

  it "new form" do
    for po in Post.subclasses
      @post = Factory.build(po.name.downcase.to_sym)

      stub_template "posts/_#{po.name.downcase}" => ""
      render
      assert_select "div"
      rendered.should contain("发布")
    end
  end
end

describe "posts/edit.html.haml" do
  it "edit form" do
    Post.subclasses.each do |po|
      # @post = Factory.build(po.name.downcase.to_sym)
      # stub_template "posts/_#{po.name.downcase}" => ""
      # render 
      # assert_select "div"
      # unless @post[:content].nil?
      #   rendered.should contain(@post[:content])
      # end
    end
  end
end
