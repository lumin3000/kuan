class LinkView < PostView
  expose :@post, :title, :url
  expose_without_escape :@post, :content

  def link
    self
  end
end
