class Favor
  include Mongoid::Document
  include Mongoid::Timestamps
  referenced_in :post
  embedded_in :user, :inverse_of => :favors

  validates_presence_of :post

  LIMIT = 1000
end
