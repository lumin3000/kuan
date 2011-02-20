module ApplicationHelper
  def render_post(p)
    type = p.class.to_s.downcase!
    template = "posts/#{type}"
    render partial: "posts/post", object: p,
      locals: { sub_template: template }
  end
end
