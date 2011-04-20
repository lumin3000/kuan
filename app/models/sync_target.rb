class SyncTarget
  include Mongoid::Document
  referenced_in :blog
end
