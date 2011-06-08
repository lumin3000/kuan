# -*- coding: utf-8 -*-
class Pics < Post
  field :content
  embeds_many :photos

  attr_accessible :photos, :content
  before_validation :sanitize_content

  validates_length_of :photos,
  minimum: 1,
  too_short: "请先上传图片"

  class << self
    def new(attrs = {})
      photos = attrs.delete :photos
      attrs[:photos] = photos.map do |p|
        p[:image] = Image.all.for_ids(p[:image]).first
        Photo.new(p)
      end if photos.is_a? Array
      super attrs
    end
  end

  def update_attributes(attrs = {})
    photos = attrs.delete :photos
    if photos.is_a? Array
      self.photos.destroy_all
      photos.each do |p|
        p.delete :id
        p[:image] = Image.all.for_ids(p[:image]).first
        self.photos << Photo.new(p)
      end
    end
    super(attrs)
  end

end
