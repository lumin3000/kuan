module BlogsHelper
  def follow_tag(blog)
    render partial: "blogs/follow_toggle", locals: { blog: blog }
  end
end
