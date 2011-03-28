require 'spec_helper'

describe ApplicationHelper do
  before :each do
  end

  it "should render post" do
    for po in Post.subclasses
      # error waitting 
      # assign(:p, Post.new)
      # post = Factory.build po.name.downcase.to_sym
      # unless post[:content].nil?
      #   helper.render_post(post).should be_include(post.content)
      # end
    end
  end

  describe "truncate_content" do
    before :each do
      @user = Factory.build(:user_unique)
      @blog = @user.create_primary_blog!
      @user.save
      @blog.save
      @post = Text.new
      @post.author_id = @user.id
      @post.blog_id = @blog.id
      @post.content = '1234567890'
      @post.save!
      @path = post_path(@post)
    end
    it "should not truncate content" do
      helper.content_summary(@post).should == @post.content
    end
    it "should truncate content" do
      helper.content_summary(@post, 9).should_not == @post.content
    end
    it "should strip_tags when truncate" do
      @post.content = "<span>1234567890</span>"
      @post.save!
      @post.reload
      helper.content_summary(@post, 9).should_not == @post.content
    end
    it "should not strip_tags&&truncate when content less than length after strip_tags" do
      @post.content = "<span>1234567890</span>"
      @post.save!
      @post.reload
      helper.content_summary(@post, 10).should == @post.content
    end
  end
end
