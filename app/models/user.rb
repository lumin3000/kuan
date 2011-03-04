# -*- coding: utf-8 -*-
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :email
  index :email, :unique => true
  field :salt
  field :encrypted_password
  embeds_many :followings
  embeds_many :comments_notices
  index "followings.blog_id"
  references_many :posts, :index => true

  attr_accessor :password, :code
  attr_accessible :name, :email, :password, :password_confirmation

  validates_presence_of :name, :message => "请输入用户名"
  validates_length_of :name,
    :minimum => 1,
    :maximum => 40,
    :too_short => "最少%{count}个字",
    :too_long => "最多%{count}个字"

  validates_presence_of :email, 
    :message => "请输入邮箱"
  validates_format_of :email, 
    :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, 
    :message => "邮箱格式不正确"
  validates_uniqueness_of :email, 
    :case_sensitive => false, 
    :message => "此邮箱已被使用"

  validates_presence_of :password, :message => "请输入密码", :on => :create
  validates_presence_of :password_confirmation, :message => "请再次输入密码", :on => :create
  validates_confirmation_of :password, :message => "两次密码不统一"

  validates_length_of :password,
    :minimum => 5,
    :maximum => 32,
    :too_short => "最少%{count}个字",
  :too_long => "最多%{count}个字", :unless => Proc.new { |a| a.password.blank? }

  before_save :encrypt_password, :unless => Proc.new { |a| a.password.blank? }
  
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

  #owning blog as lord or founder
  def own?(blog)
    followings.where(:auth.in => %w"lord founder").any? do |f|
      f.blog == blog
    end
  end

  #subs = subscriptions = follow blogs
  def subs
    #waitting for piginate
    followings.where(:auth => "follower").
      desc(:created_at).limit(100).
      map {|f| f.blog}
  end

  def all_blogs
    followings.map {|f| f.blog}
  end

  def auth_for(blog)
    f = followings.where(:blog_id => blog._id).first
    f.nil? ? nil : f.auth
  end

  def unread_comments_notices
    comments_notices.where(:unread => true)
  end
  
  def comments_notices_list(pagination)
    comments_notices.desc(:created_at).paginate(pagination)
  end

  def count_unread_comments_notices
    unread_comments_notices.count
  end

  def insert_unread_comments_notices!(post)
    c = comments_notices.where( :post_id => post.id )
    if(c.length > 0)
      c.destroy
    end
    comments_notices << CommentsNotice.new(:post => post)
  end

  def read_one_comments_notice!(post)
    c = comments_notices.where( :post_id => post.id ).first
    unless c.nil?
      c.update_attributes :unread => false
    end
  end

  def read_all_comments_notices!
    unread_comments_notices.each do |c|
      c.update_attributes( :unread => false )
    end
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
    uri + (Blog.where(:uri => /^#{uri}([0-9]*)$/).reduce(0) do |max, b|
             n = b.uri.match(/^#{uri}([0-9]*)$/)[1].to_i
             (n > max) ? n : max
           end.to_i+1).to_s
  end

end
