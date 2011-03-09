class LinkView < PostView
  expose :@post, :title, :url
  expose_without_escape :@post, :content

  def link
    true
  end

  def link_url
    @post.url
  end
end
