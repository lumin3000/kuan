class ImportFeed
  include Mongoid::Document

  field :as_type, :type => Symbol
  field :is_new, :type => Boolean, :default => true

  referenced_in :feed

  embedded_in :blog, :inverse_of => :import_feeds

  validates_inclusion_of :as_type, :in => [:text, :pic, :link]
end
