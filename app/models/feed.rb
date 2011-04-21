class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :uri
  field :imported_count, :type => Integer
  index :imported_count

  validates_presence_of :uri
  validates_uniqueness_of :uri
end
