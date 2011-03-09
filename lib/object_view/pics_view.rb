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
end
