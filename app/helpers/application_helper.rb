module ApplicationHelper
  def render_post(p)
    type = p.class.to_s.downcase!
    template = "post/#{type}"
    render partial: "post/post", object: p,
      locals: { sub_template: template }
  end
end
