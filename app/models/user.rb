# -*- coding: utf-8 -*-
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :email
  field :salt
  field :encrypted_password
  embeds_many :followings

  attr_accessor :password, :code
  attr_accessible :name, :email, :password, :password_confirmation

  validates :name, :presence => true,
  :length => {:maximum => 10}

  validates :email, :presence => true,
  :format => {:with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i},
  :uniqueness => {:case_sensitive => false}

  validates :password, :presence => true,
  :confirmation => true,
  :length => {:within => 5..10}

  before_save :encrypt_password
  before_save :email_downcase

  def has_password?(password)
    encrypted_password == encrypt(password)
  end

  class << self
    def authenticate(email, password)
      user  = User.where(:email => email).first
      return nil, :email if user.nil?
      (user.has_password? password) ? user : [nil, :password]
    end

    def authenticate_with_salt(id, salt)
      user = id ? find(id) : nil
      (user && user.salt == salt) ? user : nil
    end

    def find_by_code(code)
      begin
        find(code.to_i(32).to_s(16))
      rescue BSON::InvalidObjectId
        nil
      end
    end
  end

  #invitation code
  def inv_code
    _id.to_s.to_i(16).to_s(32)
  end

  #primary blog = user's default blog
  def create_primary_blog!
    blog = Blog.new(:title => name,
                    :uri => uri_by_name)
    blog.primary = true
    blog.save
    follow! blog, "lord"
    blog
  end

  def primary_blog
    followings.where(:auth => "lord").first.blog
  end

  def follow!(blog, auth="follower")
    f = followings.where(:blog_id => blog._id).first
    if f.nil?
      followings << Following.new(:blog => blog, :auth => auth)
    else
      f.update_attributes :auth => auth
    end
  end

  def unfollow!(blog)
    followings.where(:blog_id => blog._id).destroy
  end

  #all editable blogs, lord > founder > member > follower
  def blogs
    followings.excludes(:auth => "follower").sort do |a, b|
      next 0 if a.auth == b.auth
      next -1 if a.auth == "lord"
      next -1 if a.auth == "founder" && b.auth == "member"
      1
    end.map {|f| f.blog}
  end

  #subs = subscriptions = follow blogs
  def subs
    #waitting for piginate
    followings.where(:auth => "follower").
      desc(:created_at).limit(100).
      map {|f| f.blog}
  end

  private

  def email_downcase
    self.email.downcase!
  end

  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt password
  end

  def make_salt
    secure "#{Time.now.utc}--#{password}"
  end

  def encrypt(password)
    secure "#{salt}--#{password}"
  end

  def secure(string)
    Digest::SHA2.hexdigest string
  end

  #1,将中文名字转成域名允许的格式，并填充到4
  #2,读取数据库中已有uri,如重名则在后面加数字
  #3,如同名uri已有多个，则取后面数字最大的并+1拼出新的uri
  def uri_by_name
    require 'pinyin'
    uri = PinYin.instance.to_pinyin(name).downcase.ljust(4,'k')
    return uri if Blog.where(:uri => uri).empty?
    uri + (Blog.where(:uri => /^#{uri}/).reduce(0) do |max, b|
             n = b.uri.match(/^#{uri}([0-9]*)$/)[1].to_i
             (n > max) ? n : max
           end.to_i+1).to_s
  end
end
