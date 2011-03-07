module ObjectView
  def self.wrap(obj, extra = {})
    (obj.class.name + "View").constantize.new(obj, extra)
  end

  def respond_to?(method)
    klass = self.class
    begin
      return true if klass.public_instance_methods(false).include? method
      klass = klass.superclass
    end while klass.name[-4..-1] == 'View'
    false
  end
end

class BlogView < Mustache
  include ObjectView

  def initialize(blog, extra = {})
    @blog = blog
    @posts = extra[:posts] && extra[:posts].map {|p| ObjectView.wrap(p, extra)}
    @url_template = extra[:url_template]
    @extra = extra
    self.template = blog.custom_html.blank? ? blog.template.html : blog.custom_html
  end

  def title
    @blog.title
  end

  def posts
    @posts
  end

  def post_single
    @extra[:post_single]
  end

  def load_comments
    <<EOF
  <iframe border=0 width='594px' scrolling=NO style="overflow-x: hidden; overflow-y: scroll" src="#{@posts[0].url_for_comments}"></iframe>
EOF
  end

  def url
    @extra[:base_url]
  end

  def home_url
    @url_template % 'www'
  end

  def icon_180
    @blog.icon.url_for(:large)
  end

  def icon_60
    @blog.icon.url_for(:medium)
  end

  def icon_24
    @blog.icon.url_for(:small)
  end
end

Dir[Rails.root.join('lib/object_view/*.rb')].each {|f| require f}
