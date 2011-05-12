class ImportFeed
  include Mongoid::Document

  field :as_type, :type => Symbol
  field :is_new, :type => Boolean, :default => true
  referenced_in :author, :class_name => 'User'
  referenced_in :feed

  embedded_in :blog, :inverse_of => :import_feeds

  validates_inclusion_of :as_type, :in => [:text, :pics, :link]
  validates_presence_of :author_id
  validates_presence_of :feed_id

  scope :find_by_id, lambda { |id| where(:feed_id => id) }
end
