class Pics < Post
  field :content
  embeds_many :photos

  attr_accessible :photos, :content

  def update_attributes(attrs = {})
    photos = attrs.delete :photos
    if photos.is_a? Array
      photos = photos.map do |p|
        i = Image.criteria.id(p[:image]).first
        p[:image] = i
        Photo.new(p)
      end
    end
    attrs[:photos] = photos
    super(attrs)
  end

  validates_length_of :photos, :minimum => 1
end
