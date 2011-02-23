class Blog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uri
  field :title
  field :primary, :type => Boolean, :default => false
  references_many :followings
   
  attr_accessible :uri, :title

  validates :uri, :presence => true,
  :format => {:with => /^[0-9a-z-]{4,30}$/i},
  :uniqueness => {:case_sensitive => false}
  validates :title, :presence => true,
  :length => {:maximum => 40}

  def followed?(user)
    !user.followings.where(:blog_id => _id, :auth => "follower").empty?
  end

  def edited?(user)
    !user.followings.where(:blog_id => _id).excludes(:auth => "follower").empty?
  end

end
