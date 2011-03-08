class LinkView < PostView
  expose_with_h :@post, :title, :url
  expose :@post, :content

  def link
    self
  end
end
