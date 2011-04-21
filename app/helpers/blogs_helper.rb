module BlogsHelper
  def follow_tag(blog)
    render partial: "blogs/follow_toggle", locals: { blog: blog }
  end

  def blog_type(blog)
    if blog.primary?
      "primary"
    elsif blog.private?
      "private"
    else
      "public"
    end
  end
end
