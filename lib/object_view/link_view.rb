class LinkView < PostView
  expose :@post, :title
  expose_without_escape :@post, :content

  def link
    true
  end

  def shared_url
    @post.url
  end
end
