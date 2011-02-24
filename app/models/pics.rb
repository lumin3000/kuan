class Pics < Post
  field :content
  embeds_many :photos

  attr_accessible :photos, :content

  def update_attributes(attrs = {})
    photos = attrs.delete :photos
    if photos.is_a? Array
      old_photos = self.photos.to_a.dup
      photos.each do |p|
        id = p.delete :id
        if id.nil? || id.empty?
          i = Image.criteria.id(p[:image]).first
          next if i.nil?
          p[:image] = i
          np = Photo.new(p)
          self.photos << np
          np.save
        else
          photo = self.photos.detect do |p|
            p._id.to_s == id
          end
          next if photo.nil?
          photo.update_attributes!(p)
          old_photos.delete_if do |p|
            p._id.to_s == id
          end
        end
      end
      old_photos.each do |p|
        p.destroy
      end
    end
    super(attrs)
  end

  validates_length_of :photos, :minimum => 1
end
