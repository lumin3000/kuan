class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content
  embedded_in :post, :inverse_of => :comments
  referenced_in :author, :class_name => 'User'
  attr_accessible :content, :post, :author

  validates_presence_of :content, :message => "empty content"

end
