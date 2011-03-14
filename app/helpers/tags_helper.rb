module TagsHelper
  def tags_value(tags)
    (tags.nil? or tags.empty?) ? '' : tags.join(',')
  end

  def tags_for_post_form(post, blog)
    post.tags << blog.tag unless blog.nil?
    tags_value post.tags
  end

end
