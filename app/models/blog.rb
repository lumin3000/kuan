class Blog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uri
  field :title
  field :primary, :type => Boolean, :default => false
  references_many :followings
  references_many :posts

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

  def customed?(user)
    !user.followings.where(:blog_id => _id).any_in(:auth => ["founder", "lord"]).empty?
  end

  def followers_count
    User.where("followings.blog_id" => _id,
               "followings.auth" => "follower").count
  end

  def followers
    User.where("followings.blog_id" => _id,
               "followings.auth" => "follower").
      desc("followings.created_at").limit(100)
  end
end
