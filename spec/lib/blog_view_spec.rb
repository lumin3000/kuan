# encoding: utf-8

require 'spec_helper'
require 'cgi'

describe BlogView do
  before :each do
    @blog = Factory.build :blog_unique
    @text = Factory.build :text, :content => 'howdy ho!'
    @posts = [@text]
    @view = BlogView.new @blog, :posts => @posts
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
        @blog.custom_html = "YEEEEEEEhaa~ {{#posts}}{{#text}}{{instance_variables}}{{shit}}{{/text}}{{/posts}}"
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
      @blog.using_custom_html = false
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

  describe "Now let's play with html shit" do
    before :each do
      @text.content = "<i>blah</i>"
      @text.title = "<my world>"
      @blog.title = ">.<"
      @blog.using_custom_html = false
      @view.template = <<TPL
  {{title}}
  {{{title}}}
  {{#posts}}
    {{#text}}
      {{title}}
      {{content}}
      {{{content}}}
    {{/text}}
  {{/posts}}
TPL
      @rendered = @view.render
    end

    it "should do escaping right" do
      @view.title.should be_html_safe
      @view.title.should == CGI.escapeHTML(@blog.title)
      @rendered.should be_include(@view.title)
      @rendered.should_not be_include(@blog.title)
    end

    it "should not escape fields which claimed safe" do
      content = @view.posts[0].content
      content.should be_html_safe
      content.should == @text.content
      @rendered.should be_include content
      @rendered.should_not be_include CGI.escapeHTML(content)
    end
  end

  describe "Given a template with {{#define}} block" do
    before :each do
      @template = <<TPL
  {{#define}}
    color foo aha #333
  {{/define}}

  {{color_foo}}
TPL
      @blog.custom_html = @template
      @blog.using_custom_html = true
      @view = BlogView.new @blog, :posts => [@text]
      @rendered = @view.render
    end

    it "should extract variables" do
      variables = @view.instance_variable_get :@variables
      variables.should be_kind_of Hash
      @view.should be_respond_to(:color_foo)
      @rendered.should_not be_include('aha')
      @rendered.should_not be_include('color')
      @rendered.should_not be_include('foo')
    end

    it "should ... I'm running out of words" do
    end

    it "should insert variable" do
      variables = @view.instance_variable_get :@variables
      color_value = variables[:color][:foo][:value]
      @rendered.should be_include(color_value)
    end
  end
end

describe "BlogView.parse_custom_vars" do
  describe "given a series of user defined vars" do
    before :each do
      @input = <<EOF
  color   foo 	  背景色 #333 	
  color   shit 	   3字段，被忽略
  bool  show_comments 显示评论 1
  undefined_type mess_you_up ahahahahahah blah
EOF
      @result = {
        color: {
          foo: {
            desc: '背景色',
            value: '#333',
          }
        },
        bool: {
          show_comments: {
            desc: '显示评论',
            value: true,
          }
        },
        text: {

        },
        font: {

        },
      }
    end

    it "should parse it as expected" do
      parsed = BlogView.parse_custom_vars @input
      parsed.should == @result
    end
  end
end
