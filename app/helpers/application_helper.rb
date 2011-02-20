module ApplicationHelper
  def render_post(p)
    _type = p._type.downcase!
    template = "posts/#{_type}"
    render partial: "posts/post", object: p,
      locals: { sub_template: template }
  end

  def js(*files)
    @js = [] if @js.nil?
    files.each do |f|
      @js << capture do
        f
      end
    end
  end

  def render_form(p)
    _type = p._type.downcase
    template = "posts/form_#{_type}"
    render partial: "posts/form", object: p,
    :locals => { sub_template: template }
  end

  def form_t(par)
    if par[:id].nil?
      url = "/posts"
      m = :post
    else
      url = "/posts/#{par[:id]}"
      m = :put
    end
    form_tag(url, :method => m, :remote => true)
  end
end
