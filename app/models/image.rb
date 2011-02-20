require 'mini_magick'
require 'pp'

class Image
  include Mongoid::Document

  field :description
  field :small
  field :large
  field :original

  def self.create_from_original(file, desc = nil)
    image = Image.new()
    image.description = desc

    grid = Mongo::Grid.new(image.db)
    original_path = "image/#{image._id.to_s}/o.jpg"

    id = grid.put(file,
                  filename: original_path,
                  content_type: "image/jpg",
                  )
    image.original = id
    image.save
    image
  end
end
