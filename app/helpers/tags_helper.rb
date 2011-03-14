module TagsHelper
  def tags_value(tags)
    (tags.blank?) ? '' : tags.join(',')
  end

  def tags_for_post_form(post, blog)
    post.tags << blog.tag if post.tags.blank? && !blog.nil? && !blog.tag.blank?
    tags_value post.tags
  end

end
