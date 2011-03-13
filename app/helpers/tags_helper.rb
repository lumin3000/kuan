module TagsHelper
  def tags_value(tags)
    (tags.nil? or tags.empty?) ? '' : tags.join(',')
  end
end
