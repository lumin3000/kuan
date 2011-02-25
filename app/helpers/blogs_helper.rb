module BlogsHelper
  def fucking_url_for(blog)
    "/blog/#{blog.uri}"
  end
end
