class PhotoView
  include ObjectView

  def initialize(photo, extra = {})
    @photo = photo
    @extra = extra
  end

  expose :@photo, :desc

  { 500 => :large,
    180 => :medium,
    60 => :small, }.each do |k, v|
    define_method("image_#{k}") do
      @photo.image.url_for(v)
    end
  end

  def image_original
    @photo.image.url_for(:original)
  end
end
