class PicsView < PostView
  expose_without_escape :@post, :content

  def initialize(*)
    super
    @photos = @post.photos.map do |p|
      ObjectView.wrap p, @extra
    end
  end

  def photo_single
    @photos.length == 1
  end

  def photo_set
    !self.photo_single
  end

  def photos
    @photos
  end

  def photo_set_code_500
    return (load_js + 
      @extra[:controller].render_to_string('posts/_pics_multi', 
                                           :layout => false,
                                           :locals => {:pics_multi => @post})
            ).html_safe
  end

  def post_type
    photo_set ? "photo_set" : "photo_single"
  end
end
