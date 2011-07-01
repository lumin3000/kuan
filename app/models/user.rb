# -*- coding: utf-8 -*-
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Comet::Pusher
  
  field :name
  field :email
  index :email, unique: true
  field :salt
  field :encrypted_password
  embeds_many :followings
  index "followings.blog_id"
  embeds_many :comments_notices, validate: false
  embeds_many :messages, validate: false
  embeds_many :favors, validate: false
  index "favors.post_id"
  embeds_many :mutings, validate: false

  attr_accessor :password, :code
  attr_accessible :name, :email, :password, :password_confirmation

  validates_presence_of :name, message: "请输入用户名"
  validates_length_of :name,
    within: 1..40,
    too_short: "最少%{count}个字",
    too_long: "最多%{count}个字"
  validates_presence_of :email, 
    message: "请输入邮箱"
  validates_format_of :email, 
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, 
    message: "邮箱格式不正确"
  validates_uniqueness_of :email, 
    case_sensitive: false, 
    message: "此邮箱已被使用"

  validates_presence_of :password, message: "请输入密码", :on => :create
  validates_confirmation_of :password, message: "两次密码不统一", :on => :update

  validates_length_of :password,
    within: 5..32,
    too_short: "最少%{count}个字",
    too_long: "最多%{count}个字",
    :unless => Proc.new { |a| a.password.blank? }

  before_save :encrypt_password, :unless => Proc.new { |a| a.password.blank? }
  before_save :email_downcase

  comet_channel -> user { "/user/#{user.id}" }

  class << self
    def authenticate(email, password)
      user  = User.where(:email => email.downcase).first
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

  def has_password?(password)
    encrypted_password == encrypt(password)
  end

  #invitation code
  def inv_code
    _id.to_s.to_i(16).to_s(32)
  end

  #user and blog's relationships

  #primary blog = user's default blog
  def create_primary_blog!
    blog = Blog.new(:title => name,
                    :uri => uri_by_name)
    blog.primary = true
    blog.save
    follow! blog, "lord"
    blog
  end

  def follow!(blog, auth="follower", message_send=true)
    f = followings.where(blog_id: blog.id).first
    if f.nil?
      followings << Following.new(blog: blog, auth: auth)
      if auth == "follower" and message_send
        (blog.founders + blog.lord.to_a).each do |founder|
          founder.receive_message! Message.new(sender: self,
                                             blog: blog,
                                             type: "follow"
                                             )
        end
      end
    else
      f.update_attributes auth: auth
    end
  end

  def unfollow!(blog)
    followings.where(blog_id: blog._id).destroy
  end

  #Getting user's blogs 

  #The user should have and only have one primary blog
  def primary_blog
    followings.where(:auth => "lord").first.blog
  end

  def primary_blog!(blog)
    return false unless blog.primariable?(self)
    p_blog = self.primary_blog #must get primary_blog before lord!(blog)
    lord!(blog) && unlord!(p_blog)
  end

  def lord!(blog)
    f = followings.where(:blog_id => blog.id).first
    !f.nil? &&
    blog.primary! &&
    f.update_attributes(:auth => "lord")
  end

  def unlord!(blog)
    f = followings.where(:blog_id => blog.id).first
    !f.nil? &&
    blog.unprimary! &&
    f.update_attributes(:auth => "founder")
  end

  def icon
    primary_blog.icon
  end

  #All editable blogs, lord > founder > member > follower
  def blogs
    followings.excludes(:auth => "follower").sort do |a, b|
      next 0 if a.auth == b.auth
      next -1 if a.auth == "lord"
      next -1 if a.auth == "founder" && b.auth == "member"
      1
    end.map {|f| f.blog}
  end

  #All following blogs
  def subs
    followings.where(:auth => "follower").desc(:created_at).map {|f| f.blog}
  end

  def all_blogs
    followings.map {|f| f.blog}
  end

  def other_blogs
    followings.reduce [] do |blogs, f|
      blogs.push f.blog if %w{founder member}.include? f.auth
      blogs
    end
  end

  def auth_for(blog)
    f = followings.where(:blog_id => blog._id).first
    f.nil? ? nil : f.auth
  end

  #Favors operations
  
  def add_favor_post!(post)
    return if post.nil?
    del_favor_post! post
    favors << Favor.new(:post => post)
    favors.first.delete if favors.length > Favor::LIMIT
    post.favor_count_inc 
  end

  def del_favor_post!(post)
    f = favors.where(post_id: post.id).first
    unless f.nil?
      f.destroy
      post.favor_count_dec 
    end
  end

  def favor_posts
    favors.reduce([]) do |posts, f|
      posts << f.post unless f.post.nil?
      posts
    end
  end

  #Messages operations

  def receive_message!(message)
    c = messages.where(sender_id: message.sender.id,
                       blog_id: message.blog.id,
                       type: message.type)
    c.destroy_all if c.count > 0
    messages << message
    messages.first.delete if messages.length > Message::LIMIT
    push_to_comet messages_count: messages.unreads.length
  end

  def read_all_messages!
    messages.each {|m| m.read!} 
  end

  #Comments' notices operations
  
  def comments_notices_list
    comments_notices.desc(:created_at)
  end

  def unread_comments_notices_list
    comments_notices.where(unread: true).desc(:created_at)
  end

  def insert_unread_comments_notices!(post)
    c = comments_notices.where(post_id: post.id)
    c.destroy if c.length > 0
    comments_notices.first.delete if comments_notices.length > 99
    comments_notices << CommentsNotice.new(post: post)
    push_to_comet comments_count: comments_notices.unreads.length
  end

  def read_all_comments_notices!
    comments_notices.unreads.each do |c|
      c.read!
    end
  end

  def read_post(post)
    notice = comments_notices.get_by_post(post).first
    notice.read! unless notice.nil?
    push_to_comet comments_count: comments_notices.unreads.length
  end

  #mute/unmute operations

  def mute!(post)
    mutings << Muting.new(:post => post) unless post.muted_by?(self)
  end

  def unmute!(post)
    mutings.where(:post_id => post.id).destroy 
  end

  #template operations

  def submit_template(params)
    params.update :author => self
    Template.create_by_submit params
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
    require 'chinese/pinyin'
    uri = PinYin.instance.to_pinyin(name).downcase.to(29).ljust(4,'k')
    return uri if Blog.where(:uri => uri).empty?
    uri + (Blog.where(:uri => /^#{uri}([0-9]*)$/).reduce(0) do |max, b|
             n = b.uri.match(/^#{uri}([0-9]*)$/)[1].to_i
             (n > max) ? n : max
           end.to_i+1).to_s
  end

end
