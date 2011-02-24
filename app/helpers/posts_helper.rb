module PostsHelper
  def render_post(p)
    type = p.type.downcase
    if type == "pics"
      type = if p.photos.length != 1
        "pics_multi"
      else
        "pics_single"
      end
    end
    template = "posts/#{type}"
    render partial: "posts/post", object: p,
      locals: { sub_template: template, type: type }
  end

  def render_form(p)
    _type = p._type.downcase
    template = "posts/form_#{_type}"
    render partial: "posts/form", object: p,
    :locals => { sub_template: template }
  end
  
  def render_form_photo(p)
    render partial: "posts/form_photo", object: p
  end

  def form_t(par)
    if par[:id].nil?
      url = "/posts"
      m = :post
    else
      url = "/posts/#{par[:id]}"
      m = :put
    end
    form_tag url, :method => m, :remote => true, do
      yield
    end
  end
end
