class Pics < Post
  field :content
  embeds_many :photos

  attr_accessible :photos, :content

  validates_length_of :photos, :minimum => 1
end
