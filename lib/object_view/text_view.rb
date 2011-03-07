class TextView < PostView
  def_delegators :@post, :title, :content

  def text
    self
  end
end
