module UrlHelper
  def with_subdomain(subdomain)
    subdomain ||= ""
    subdomain += '.' unless subdomain.blank?
    [subdomain, request.domain, request.port_string].join
  end

  def url_for(options = nil)
    if options.kind_of?(Hash) && options.has_key?(:subdomain)
      options[:host] = with_subdomain(options.delete(:subdomain))
    end
    super
  end

  def url_with_subdomain(subdomain)
    'http://'+with_subdomain(subdomain)
  end

  def url_for_blog_(blog)
    raise "fffffffuuuuuuuuuuuuu" if blog.nil?
    root_url(:subdomain => blog.uri)
  end

  alias blog_path url_for_blog_

  def edit_blog_path(blog)
    url_for_blog_(blog) + 'edit'
  end

  def followers_blog_path(blog)
    url_for_blog_(blog) + 'followers'
  end

  def follow_toggle_blog_path(blog)
    (request.subdomain == blog.uri) ? (url_for_blog_(blog)+'follow_toggle') : super
  end

  def editors_blog_path(blog)
    url_for_blog_(blog) + 'editors'
  end

  def editor_blog_path(blog, user)
    url_for_blog_(blog) + 'editor/' + user.id.to_s
  end

  def posts_blog_path(post)
    url_for_blog_(post.blog) + "posts/#{post.id}"
  end

  def tagged_path(tag)
    super tag_escape(tag)
  end

  def tag_escape(tag)
    tag.gsub('.', '$k*').gsub('/', '^k*')
  end

  def tag_unescape(tag)
    tag.gsub('$k*', '.').gsub('^k*', '/')
  end

  def fucking_root
    root_url(:subdomain => 'www')
  end

  def contact_address
    "kuankuandao@gmail.com"
  end

  def current_url(p={})
    url_for p.merge({only_path: false})
  end
end
