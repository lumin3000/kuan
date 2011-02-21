class Pics < Post
  field :content
  embeds_many :photo
  attr_accessible :images, :content
end
