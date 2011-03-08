class TextView < PostView
  def text
    self
  end

  expose :@post, :title
  expose_without_escape :@post, :content
end
