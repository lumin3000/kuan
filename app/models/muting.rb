class Muting
  include Mongoid::Document
  referenced_in :post, :validate => false
  embedded_in :user, :inverse_of => :mutings

  validates_presence_of :post
end
