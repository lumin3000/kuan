require 'spec_helper'

describe BlogView do
  before :each do
    @blog = Factory.build :blog_unique
    @view = BlogView.new @blog
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
      @text = Factory.build :text, :content => 'howdy ho!'
      @text_wrapper = {:text => @text}
      @posts = [@text_wrapper]
    end

    it "should be able to render" do
      @view = BlogView.new @blog, :posts => @posts
      rendered = @view.render
      rendered.should be_include 'Hello'
      rendered.should be_include @blog.title
      rendered.should be_include @text.content
    end

    describe "when a cracker tries to call method on model" do
      before :each do
        @text.define_singleton_method :shit do
          raise "Shit hits the fan!"
        end
        @blog.custom_html = "YEEEEEEEhaa~ {{#posts}}{{#text}}{{shit}}{{/text}}{{/posts}}"
        @view = BlogView.new @blog, :posts => [@text_wrapper]
      end

      it "shouldn't break" do
        pending "waiting for wrapper"
        rendered = @view.render
        rendered.should == "YEEEEEEEhaa~ "
      end
    end
  end
end
