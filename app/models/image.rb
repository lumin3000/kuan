require 'mini_magick'

class Image
  include Mongoid::Document

  AVAIL_VERSIONS = [:original, :large, :medium, :small]

  AVAIL_VERSIONS.each do |v|
    field v
  end

  def self.calc_scale(from, to)
    scale_w = to[0].fdiv from[0]
    scale_h = to[1].fdiv from[1]
    min, max = scale_h > scale_w ? [scale_w, scale_h] : [scale_h, scale_w]
    if min > 0 then min else max end
  end

  def self.create_from_original(file, process_spec = {})
    raise "File not available" if not file.respond_to? :read

    image = Image.new()

    grid = Mongo::Grid.new(image.db)
    original_image = MiniMagick::Image.read file
    type = original_image["format"].downcase!
    mime = "image/#{type}"
    original_blob = original_image.to_blob

    id = grid.put original_blob, :content_type => mime
    image.original = id

    process_spec.each do |version, geometry|
      next if not AVAIL_VERSIONS.include? version
      scale = self.calc_scale(original_image['dimensions'], geometry)
      i = MiniMagick::Image.read(original_blob)
      i.resize "#{scale*100}%" if scale < 1
      id = grid.put i.to_blob, :content_type => mime
      image.send "#{version}=", id
    end

    image.save
    image
  end

  def url_for(version = :original)
    if AVAIL_VERSIONS.include? version
      id = self.send version
      "/gridfs/#{id}" if not id.nil?
    end
  end

  def to_json()
    hash = {id: self.id}
    AVAIL_VERSIONS.each do |k|
      url = self.url_for k
      hash[k] = url if not url.nil?
    end
    hash.to_json
  end
end
