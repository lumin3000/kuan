require 'mini_magick'

class Image
  include Mongoid::Document

  field :small
  field :large
  field :original

  Versions = [:original, :large, :small]

  def self.create_from_original(file)
    raise "File not available" if not file.respond_to? :read

    image = Image.new()

    grid = Mongo::Grid.new(image.db)
    original_path = "image/#{image._id.to_s}/o.jpg"

    id = grid.put(file,
                  filename: original_path,
                  )
    image.original = id
    image.save
    image
  end

  def url_for(version = :original)
    if Image::Versions.include? version
      # TODO: provide multiple version of images
      id = self.original
      "/gridfs/#{id}"
    else
      nil
    end
  end
end
