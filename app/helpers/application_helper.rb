module ApplicationHelper
  def render_post(p)
    type = p.class.to_s.downcase!
    template = "post/#{type}"
    render partial: template, object: p
  end
end
