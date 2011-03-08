class TextView < PostView
  def text
    self
  end

  expose_with_h :@post, :title
  expose :@post, :content
end
