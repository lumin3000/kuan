class Pics < Post
  field :content
  embeds_many :photos
  attr_accessible :photos, :content
end
