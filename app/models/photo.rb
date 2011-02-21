class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :desc
  referenced_in :image

  embedded_in :pics, :inverse_of => :photos

  attr_accessible :desc, :pics, :image
end
