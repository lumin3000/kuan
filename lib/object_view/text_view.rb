class TextView < PostView
  def text
    true
  end

  expose :@post, :title
  expose_without_escape :@post, :content
end
