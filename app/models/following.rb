class Following
  include Mongoid::Document
  include Mongoid::Timestamps
  field :auth
  referenced_in :blog
  embedded_in :user, :inverse_of => :followings

  validates :auth,
  :inclusion => {:in => %w[follower member founder lord]}

end
