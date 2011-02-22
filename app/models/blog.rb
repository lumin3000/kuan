class Blog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uri
  field :title
  references_many :followings
  
  attr_accessible :uri, :title

  validates :uri, :presence => true,
  :format => {:with => /^[0-9a-z-]{6,30}$/i},
  :uniqueness => {:case_sensitive => false}
  validates :title, :presence => true,
  :length => {:maximum => 40}
  
end
