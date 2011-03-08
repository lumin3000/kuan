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

  def blog_apply_path(blog)
    fucking_root() + "blogs/#{blog.uri}/apply"
  end

  # Private!
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
    url_for_blog_(blog) + 'follow_toggle'
  end

  def fucking_root
    root_url(:subdomain => 'www')
  end

end
