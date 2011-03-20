class LinkView < PostView
  expose_without_escape :@post, :content

  def link
    true
  end

  def shared_url
    h @post.url
  end

  def title
    title = @post.title
    title.blank? ? shared_url : h(title)
  end
end
