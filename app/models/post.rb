# encoding: utf-8
class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :blog, :index => true
  referenced_in :author, :class_name => 'User', :index => true
  embeds_many :comments
  index :created_at

  field :parent_id
  field :ancestor_id
  index :ancestor_id
  field :private, :type => Boolean, :default => false
  field :repost_count, :type => Integer, :default => 0
  field :favor_count, :type => Integer, :default => 0
  field :tags, :type => Array, :default => []
  index :tags

  attr_accessible :blog, :author, :author_id, :blog_id, :created_at, :comments, :parent, :tags, :private

  validates_presence_of :author_id
  validates_presence_of :blog_id, :message => "请选择要发布到的页面"

  validate :posted_to_editable_blogs, :if => :new_record?

  before_destroy :clean_comments_notices
  before_create :type_setter, :private_setter
  after_create :ancestor_reposts_inc, :update_blog

  scope :publics, where(:private.ne => true).desc(:created_at)
  scope :all, desc(:updated_at)
  scope :tagged, lambda { |tag| where(:tags => tag, :private.ne => true).desc(:created_at) }
  scope :pics_and_text, where(:_type.in => ["Text", "Pics"], :private.ne => true)
  scope :in_day, lambda { |date| where(:created_at.gte => date.midnight,
                                       :created_at.lte => date.end_of_day).desc(:created_at) }

  def haml_object_ref
    "post"
  end

  def type
    self._type.downcase
  end

  # about the repost , parent and ancestor
  def parent=(parent)
    self.created_at = self.updated_at = Time.now
    return if parent.nil?
    self.parent_id = parent.id
    self.ancestor_id = parent.ancestor.nil? ? parent.id : parent.ancestor.id
  end

  def parent
    Post.criteria.id(parent_id).first unless parent_id.nil?
  end

  def ancestor
    return nil if ancestor_id.nil?
    a = Post.criteria.id(ancestor_id).first
    a ||= parent
  end

  def tags=(tags)
    super Tag::trans(tags)
  end

  class << self
    def new(args = {})
      type = args.delete :type
      return super if type.nil?
      klass = Object.const_get type.capitalize
      (self.subclasses.include? klass) ? klass.new(args) : nil
    end

    def news(pagination)
      Blog.latest.paginate(pagination).reduce([]) do |posts, b|
        post = b.posts.desc(:created_at).limit(1).first
        posts << post if not post.nil? and post.created_at == b.posted_at
        posts
      end
    end

    def wall
      Blog.latest[0..200].sample(50).reduce([]) do |posts, b|
        p = b.posts.pics_and_text.desc(:created_at).limit(10)
        p.blank? ? posts : (posts << p.sample)
      end
    end

    def accumulate_for_tags(cal_date = Date.yesterday)
      old_hots = Tag.hottest.to_a
      Post.in_day(cal_date).where(:tags => /.+/).reduce({}) do |tags, post|
        post.tags.each { |tag| tags.key?(tag) ? (tags[tag] += 1) : (tags[tag] = 1) }
        tags
      end.each { |tag, count| Tag.accumulate tag, count, cal_date.to_s }
      Tag.set_new_hots old_hots
    end
  end

  # Must stub this out
  def photos(*args)
  end

  def editable_by?(user)
    return false if user.nil?
    author == user || blog.customed?(user)
  end

  def favored_by?(user)
    not user.nil? and user.favor_posts.include? self
  end

  def favor_count_inc
    favor_count.nil? ? update_attributes(:favor_count => 1) : inc(:favor_count, 1)
  end

  def favor_count_dec
    favor_count.nil? ? update_attributes(:favor_count => 0) : inc(:favor_count, -1)
  end

  def notify_watchers(comment)
    watchers = self.watchers
    watchers.delete comment.author
    watchers.each do |w|
      w.insert_unread_comments_notices!(self)
    end
  end

  def watchers
    watchers =  self.comments.map {|f| f.author}
    watchers << self.author
    watchers.uniq
  end

  private

  def update_blog
    blog.update_attributes(:posted_at => created_at)
    blog.handle_sync(self)
  end

  def type_setter
    self._type = self.class.to_s
  end

  def private_setter
    self.private = self.blog.private
    ensure return true
  end

  def clean_comments_notices
    watchers.each do |u|
      u.comments_notices.destroy_all(:conditions => { :post_id => self.id })
    end
  end

  def posted_to_editable_blogs
    return if author_id.nil? || blog_id.nil?
    author = User.find(self.author_id)
    blog = Blog.find(self.blog_id)
    errors.add :blog, "放开那博客" unless author.blogs.include? blog
  end

  def sanitize_content
    require 'filters/rich_filter'
    self.content = RichFilter.tags self.content
  end

  def ancestor_reposts_inc
    unless ancestor.nil?
      if ancestor.repost_count.nil?
        ancestor.update_attributes(:repost_count => 1)
      else
        ancestor.inc :repost_count, 1
      end
    end
  end

end
