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
    @extra[:home_url] + "tagged/#{@tag}"
  end
end
