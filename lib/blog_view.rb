module ObjectView
  def self.wrap(obj)
    (obj.class.name + "View").constantize.new(obj)
  end
end

class BlogView < Mustache
  def initialize(blog, extra = {})
    @blog = blog
    @posts = extra[:posts] && extra[:posts].map {|p| ObjectView.wrap(p)}
    self.template = blog.custom_html.blank? ? blog.template.html : blog.custom_html
  end

  AVAIL_FIELDS = %w{title posts}.map {|str| str.to_sym}

  def respond_to?(method)
    AVAIL_FIELDS.include?(method)
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

  def initialize(user)
    @user = user
  end

  def_delegators :@user, :name
end
