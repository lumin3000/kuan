# -*- coding: utf-8 -*-
require 'spec_helper'

describe "posts/new.html.haml" do
  it "new form" do
    for po in Post.subclasses
      @post = po.new

      assign(:type, po.name.downcase)
      stub_template "posts/_#{po.name.downcase}" => ""
      render
      assert_select "div"
      rendered.should contain("发布")
    end
  end
end

describe "posts/edit.html.haml" do
  it "edit form" do
    for po in Post.subclasses
      @post = Factory.create(po.name.downcase.to_sym)
      assign(:type, po.name.downcase)
      stub_template "posts/_#{po.name.downcase}" => ""
      render
      assert_select "div"
      unless @post[:content].nil?
        rendered.should contain(@post[:content])
      end
    end
  end
end
