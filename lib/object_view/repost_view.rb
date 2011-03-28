class RepostView
  include ObjectView

  def initialize(post, extra = {})
    @post = post
    @extra = extra
    @parent = post.parent
  end

  def source
    ObjectView.wrap(@parent.blog, @extra)
  end

  def target
    ObjectView.wrap(@post.blog, @extra)
  end
end
