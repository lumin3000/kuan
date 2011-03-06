module ObjectView
  def self.wrap(obj)
    (obj.class.name + "View").constantize.new(obj)
  end

  def respond_to?(method)
    self.class.public_instance_methods(false).include? method
  end
end

class BlogView < Mustache
  include UrlHelper
  include ObjectView

  def initialize(blog, extra = {})
    @blog = blog
    @posts = extra[:posts] && extra[:posts].map {|p| ObjectView.wrap(p)}
    @request = extra[:request]
    self.template = blog.custom_html.blank? ? blog.template.html : blog.custom_html
  end

  def title
    @blog.title
  end

  def posts
    @posts
  end
end

class TextView
  extend Forwardable
  include ObjectView

  def initialize(text)
    @text = text
  end

  def_delegators :@text, :title, :content

  def text
    self
  end

  def author
    ObjectView.wrap(@text.author)
  end
end

class UserView
  extend Forwardable
  include ObjectView

  def initialize(user)
    @user = user
  end

  def_delegators :@user, :name
end
