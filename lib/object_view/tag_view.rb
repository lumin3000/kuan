class TagView
  include ObjectView
  def initialize(tag, extra = {})
    @tag = tag
    @extra = extra
  end

  def name
    @tag
  end

  def url
    @extra[:controller].tagged_path @tag
  end
end
