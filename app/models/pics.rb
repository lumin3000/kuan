class Pics < Post
  references_and_referenced_in_many :images, :inverse_of => :pics
  field :content
  
  attr_accessible :images, :content
end
