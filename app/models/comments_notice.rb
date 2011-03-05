class CommentsNotice
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :unread, :type => Boolean, :default => true
  referenced_in :post

  embedded_in :user, :inverse_of => :comments_notices
end
