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
    max = [scale_w, scale_h].max
    scale = [max, 1].min
    from.map do |n|
      (n * scale).round
    end
  end

  def self.calc_offset(from, to)
    width = to[0] == 0 ? 0: [to[0] - from[0], 0].min
    height = to[1] == 0 ? 0 : [to[1] - from[1], 0].min

    [(-width) / 2, (-height) / 2]
  end

  def self.create_from_original(file, process_spec = {})
    raise "File not available" if not file.respond_to? :read

    image = Image.new()

    grid = Mongo::Grid.new(image.db)
    original_image = MiniMagick::Image.read file
    type = original_image["format"].downcase!
    mime = "image/#{type}"
    original_blob = original_image.to_blob
    orig_dimen = original_image['dimensions']

    id = grid.put original_blob, :content_type => mime
    image.original = id

    process_spec.each do |version, geometry|
      next if not AVAIL_VERSIONS.include? version
      temp_dimen = self.calc_scale(orig_dimen, geometry)
      i = MiniMagick::Image.read(original_blob)
      i.resize "#{temp_dimen[0]}x#{temp_dimen[1]}"
      w, h = i['dimensions']
      # os for offset
      os_w, os_h = self.calc_offset([w, h], geometry)
      i.shave "#{os_w}x#{os_h}"
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

  private
  def min(*args)
    args.min
  end
end
