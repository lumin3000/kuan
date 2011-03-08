class PicsView < PostView
  expose :@post, :content

  def initialize(*)
    super
    @first_photo = @post.photos.first
  end

  def photo_single
    self if @post.photos.length == 1
  end

  def photo_set
    self unless self.photo_single
  end

end
