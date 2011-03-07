class PicsView < PostView
  def_delegators :@post, :title, :content

  def initialize(*)
    super
    @first_photo = @post.photos[0]
  end

  def photo_single
    self if @post.photos.length == 1
  end

  def photo_set
    self unless self.photo_single
  end

end
