# -*- coding: utf-8 -*-
class Blog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uri
  index :uri, :unique => true
  field :title
  referenced_in :icon, :class_name => 'Image'
  field :primary, :type => Boolean, :default => false
  field :private, :type => Boolean, :default => false
  field :canjoin, :type => Boolean, :default => false
  field :posted_at, :type => Time

  scope :public, :excludes => { :private => true }
  scope :latest, :excludes => { :private => true, :posted_at => nil },
    :order_by => { :posted_at => :desc },
    :limit => 500

  references_many :followings
  references_many :posts, :index => true

  attr_accessible :uri, :title, :icon, :private, :canjoin, :posted_at

  validates_presence_of :title,
  :message => "请输入页面名字"
  validates_length_of :title,
  :minimum => 1,
  :maximum => 40,
  :too_short => "最少%{count}个字",
  :too_long => "最多%{count}个字"

  validates_presence_of :uri,
  :message => "请输入链接"
  validates_format_of :uri,
  :with => /^[0-9a-z-]+$/,
  :message => "网址仅限小写字母、数字与“-”"
  validates_length_of :uri,
  :within => 4..30,
  :message => '网址长度应在4-30个字符之间'
  validates_uniqueness_of :uri,
  :case_sensitive => false,
  :message => "此链接已被使用"
  validate do |blog|
    errors.add(:base, "默认主页不可以被申请加入") if blog.primary? and blog.canjoin?
  end

  DEFAULT_ICONS = {:large => "/images/default_icon_large.gif",
    :medium => "/images/default_icon_medium.gif",
    :small => "/images/default_icon_small.gif"}

  class << self
    def find_by_uri!(uri)
      where(:uri => uri).first
    end
  end

  alias_method :old_icon_get, :icon
  def icon
    old_icon_get || Image.create_from_default(DEFAULT_ICONS)
  end

  def followers_count
    User.collection.find({"followings" => {"$elemMatch"=> {"blog_id"=>id,"auth"=>"follower"}}}).count
  end

  def followers
    User.collection.find({"followings" => {"$elemMatch"=> {"blog_id"=>id,"auth"=>"follower"}}},
                         :sort=>[["followings.created_at", -1]],
                         :limit=>200).to_a
  end

  def founders
    User.collection.find({"followings" => {"$elemMatch"=> {"blog_id"=>id,"auth"=>"founder"}}},
                         :sort=>[["followings.created_at", -1]]).to_a
  end

  def members
    User.collection.find({"followings" => {"$elemMatch"=> {"blog_id"=>id,"auth"=>"member"}}},
                         :sort=>[["followings.created_at", -1]]).to_a
  end

  def total_post_num
    Post.where(:blog_id => id).count
  end

  def followed?(user)
    %(follower) == auth_for(user)
  end

  def unfollowed?(user)
    auth_for(user).blank?
  end

  def edited?(user)
    %w[lord founder member].include? auth_for(user)
  end

  def customed?(user)
    %w[lord founder].include? auth_for(user)
  end

  def open_to?(user)
    not private? or edited?(user)
  end

  def canexit?(user)
    not customed?(user) or founders.length > 1
  end

  def applied?(user)
    not primary? and canjoin? and not edited?(user)
  end

  def applied(sender, content = nil)
    return false unless applied? sender
    founders.each do |founder|
      founder.receive_message! Message.new(:sender => sender,
                                           :blog => self,
                                           :content => content,
                                           :type => "join")
    end
    true
  end

  def to_param
    uri.parameterize
  end

  private

  def auth_for(user)
    return nil if user.nil?
    following = user.followings.where(:blog_id => id).first
    following.nil? ? nil : following.auth
  end
end
