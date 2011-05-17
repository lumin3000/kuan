# -*- coding: utf-8 -*-
class Blog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  index :uri, :unique => true
  field :title
  field :desc
  referenced_in :icon, :class_name => 'Image'
  field :primary, :type => Boolean, :default => false
  field :private, :type => Boolean, :default => false
  field :canjoin, :type => Boolean, :default => false
  field :open_register, :type => Boolean, :default => false
  field :posted_at, :type => Time
  index :posted_at
  field :tag
  index :tag

  scope :public, :excludes => { :private => true }
  scope :latest, :excludes => { :private => true, :posted_at => nil },
  :order_by => { :posted_at => :desc },
  :limit => 500
  scope :tagged, lambda { |tag| where(:tag => tag, :private.ne => true).desc(:posted_at) }

  field :using_custom_html, :type => Boolean, :default => false
  field :custom_css
  field :custom_html
  referenced_in :template, :class_name => 'Template'

  field :template_conf, :type => Hash

  embeds_many :import_feeds
  index "import_feeds.feed_id"
  
  references_many :posts, :index => true, :validate => false
  references_many :sync_targets, :validate => false

  attr_accessible :uri, :title, :desc, :icon, :primary, :private, :canjoin,
  :posted_at, :custom_html, :open_register, :using_custom_html,
  :custom_css, :template, :template_id, :template_conf, :tag

  before_update :post_privte_setter
  before_validation :sanitize_desc

  validates_presence_of :title,
  :message => "请输入页面名字"
  validates_length_of :title,
  :within => 1..40,
  :too_short => "最少%{count}个字",
  :too_long => "最多%{count}个字"

  validates_presence_of :uri,
  :message => "请输入链接"
  validates_format_of :uri,
  :with => /^[0-9a-z-]+$/,
  :message => "网址仅限小写字母、数字与“-”"
  validates_length_of :uri,
  :within => 4..255,
  :message => '网址长度应在4-255个字符之间'
  validates_uniqueness_of :uri,
  :case_sensitive => false,
  :message => "此链接已被使用"

  validate do |blog|
    errors.add(:tag, "标签格式不正确") if not blog.tag.blank? and Tag::invalid? blog.tag
  end

  validate do |blog|
    errors.add(:base, "默认主页不可以被申请加入") if blog.primary? and blog.canjoin?
  end


  DEFAULT_ICONS = {
    :large => "/images/default_icon_180.jpg",
    :medium => "/images/default_icon_60.jpg",
    :small => "/images/default_icon_24.jpg",
    :'128' => "/images/default_icon_128.jpg",
    :'96' => "/images/default_icon_96.jpg",
    :'64' => "/images/default_icon_64.jpg",
    :'48' => "/images/default_icon_48.jpg",
    :'40' => "/images/default_icon_40.jpg",
    :'30' => "/images/default_icon_30.jpg",
    :'16' => "/images/default_icon_16.jpg",
  }

  class << self
    def find_by_uri!(uri)
      where(:uri => uri).first
    end
  end

  alias_method :old_icon_get, :icon
  def icon
    old_icon_get || Image.create_from_default(DEFAULT_ICONS)
  end

  alias_method :old_template_get, :template
  def template
    old_template_get || Template::DEFAULT
  end

  def tag=(tag)
    super((tag.blank?) ? nil : tag.strip)
  end

  def joined_count
    User.collection.find({"followings" => {
                             "$elemMatch"=> {
                               "blog_id"=>id,"auth"=> {:$in => ["lord", "member", "founder"]}
                             }
                           }}).count
  end

  def post_demo
    Post.where(
               :blog_id => id, 
               :_type.in => ["Text", "Pics"], 
               :private.ne => true).desc(:created_at).first
  end

  def primariable?(user)
    !primary && !private && customed?(user) && joined_count == 1
  end

  def primary!
    update_attributes(:primary => true,
                      :canjoin => false)
  end

  def unprimary!
    update_attributes(:primary => false)
  end

  def followers_count
    User.collection.find({"followings" => {"$elemMatch"=> {"blog_id"=>id,"auth"=>"follower"}}}).count
  end

  def lord
    User.collection.find({"followings" => {
                             "$elemMatch"=> {"blog_id"=>id,"auth"=>"lord"}
                           }}).first
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

  def import!(uri, type, author)
    feed = Feed.find_or_create_by_uri uri
    if feed.nil?
      self.errors.add :import_feed_uri, "此地址无法识别出有效的rss源" and return nil
    end
    if import_feeds.length >= 3
      self.errors.add :import_feed_uri, "对不起，目前最多只可以导入3个rss源" and return nil
    end
    unless import_feeds.where(:feed_id => feed.id).first.nil?
      self.errors.add :import_feed_uri, "此rss源已经导入过了" and return nil
    end
    import_feed = ImportFeed.new(:feed => feed, :as_type => type, :author => author)
    self.import_feeds << import_feed
    feed.inc :imported_count, 1
    import_feed
  end

  def cancel_import!(feed)
    import_feeds.where(:feed_id => feed.id).destroy
  end

  def to_param
    uri.parameterize
  end

  def use_template(params)
    [:custom_html, :using_custom_html, :template_id, :template_conf].each do |key|
      self.send "#{key}=", params[key] if params.has_key? key
    end
    normalize_template_conf
  end

  def template_in_use
    self.using_custom_html? ? self.custom_html : self.template.html
  end

  def normalize_template_conf(hash = nil)
    conf = hash || self.template_conf
    return if conf.nil?
    conf.keys.each do |k|
      if k.is_a? Symbol
        v = conf.delete k
        conf[k.to_s] = v.is_a?(Hash) ? normalize_template_conf(v) : v
      end
    end
  end

  def handle_sync(post)
    self.sync_targets.each do |t|
      t.handle_post(post) rescue nil
    end
  end

  private

  def auth_for(user)
    return nil if user.nil?
    following = user.followings.where(:blog_id => id).first
    following.nil? ? nil : following.auth
  end

  def sanitize_desc
    require 'filters/rich_filter'
    self.desc = RichFilter.tags self.desc
  end

  def post_privte_setter
    Post.where(:blog_id => id).update(:private => private?) if private_changed?
  end
end
