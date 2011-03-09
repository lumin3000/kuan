class PicsView < PostView
  expose_without_escape :@post, :content

  def initialize(*)
    super
    @first_photo = @post.photos.first
  end

  def photo_single
    @post.photos.length == 1
  end

  def photo_set
    !self.photo_single
  end

end
