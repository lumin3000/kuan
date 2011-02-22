class Pics < Post
  field :content
  embeds_many :photos

  attr_accessible :photos, :content

  def update_attributes(attrs = {})
    photos = attrs.delete :photos
    if not photos.nil?
      photos = photos.map do |p|
        Photo.new(p)
      end
    end
    attrs[:photos] = photos
    super(attrs)
  end

  validates_length_of :photos, :minimum => 1
end
