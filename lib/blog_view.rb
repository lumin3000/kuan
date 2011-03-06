class BlogView < Mustache
  def initialize(blog, extra = {})
    @blog = blog
    @posts = extra[:posts]
    self.template = blog.custom_html
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
