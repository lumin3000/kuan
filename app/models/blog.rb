# -*- coding: utf-8 -*-
class Blog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uri
  field :title
  referenced_in :icon, :class_name => 'Image'
  field :primary, :type => Boolean, :default => false
  references_many :followings
  references_many :posts

  attr_accessible :uri, :title, :icon

  validates_presence_of :title, 
    :message => "请输入用户名"
  validates_length_of :title,
    :minimum => 1,
    :maximum => 40,
    :too_short => "最少%{count}个字",
    :too_long => "最多%{count}个字"

  validates_presence_of :uri,
    :message => "请输入链接"
  validates_format_of :uri,
    :with => /^[0-9a-z-]+$/i,
    :message => "网址仅限字母、数字与“-”"
  validates_length_of :uri,
    :within => 4..30,
    :message => '网址长度应在4-30个字符之间'
  validates_uniqueness_of :uri,
    :case_sensitive => false,
    :message => "此链接已被使用"

  alias_method :old_get_icon, :icon
  def icon
    icon = old_get_icon
    (icon.nil?) ? DEFAULT_ICON : icon
  end

  DEFAULT_ICON = Image.new
  DEFAULT_ICON.define_singleton_method :url_for do |version|
    "/images/default_blog_icon.jpg"
  end
  DEFAULT_ICON.define_singleton_method :id do
    nil
  end

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

  def total_post_num
    Post.where(:blog_id => id).count
  end

  def to_param
    uri.parameterize
  end

  class << self
    def find_by_uri!(uri)
      return self.find(:first, :conditions => {:uri => uri})
    end
  end
end
