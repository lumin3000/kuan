require 'spec_helper'

describe BlogView do
  before :each do
    @blog = Factory.build :blog_unique
    @view = BlogView.new @blog
    @text = Factory.build :text, :content => 'howdy ho!'
    @posts = [@text]
  end

  it "should be safe to use" do
    @view.should_not be_respond_to :instance_variables
  end

  it "should be usable" do
    @view.should be_respond_to :title
  end

  describe "given a blog with custom html" do
    before :each do
      @blog.title = 'blah'
      @blog.custom_html = <<EOF
      Hello! {{title}}
  Oh you've got a text post:
  {{#posts}}
    {{#text}}
      {{content}}
    {{/text}}
  {{/posts}}
EOF
      @view = BlogView.new @blog, :posts => @posts
    end

    it "should be able to render" do
      rendered = @view.render
      rendered.should be_include 'Hello'
      rendered.should be_include @blog.title
      rendered.should be_include @text.content
    end

    it "should wrap models with curresponding view" do
      text = @view.posts[0]
      text.should be_instance_of TextView
      author = text.author
      author.should be_instance_of UserView
    end

    describe "when a cracker tries to call method on model" do
      before :each do
        @text.define_singleton_method :shit do
          raise "Shit hits the fan!"
        end
        @blog.custom_html = "YEEEEEEEhaa~ {{#posts}}{{#text}}{{shit}}{{/text}}{{/posts}}"
        @view = BlogView.new @blog, :posts => [@text]
      end

      it "shouldn't break" do
        rendered = @view.render
        rendered.should == "YEEEEEEEhaa~ "
      end
    end
  end

  describe "given a blog using predefined template" do
    before :each do
      @anchor = 'valid html!'
      @template = Factory.create :custom_template, :html => <<EOF
  <!doctype html>
  <title>{{title}}</title>
  <p>#{@anchor}</p>
  {{#posts}}
  <ol>
    <li>
      {{#text}}
        {{title}}
        {{content}}
      {{/text}}

      {{#link}}
        <a href="{{url}}">{{title}}</a>
        {{content}}
      {{/link}}
    </li>
  </ol>
  {{/posts}}
EOF
      @blog = Factory.build :blog_unique, :template => @template
      @blog.custom_html = nil
      @view = BlogView.new @blog, :posts => [@text]
    end

    describe "and render it " do
      before :each do
        @rendered = @view.render
      end

      it "should work as well" do
        @rendered.should be_include @anchor
        @rendered.should be_include @text.content
      end
    end
  end
end
