# encoding: utf-8
class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Sphinx
  include Comet::Pusher

  referenced_in :blog, index: true
  referenced_in :author, class_name: 'User', index: true
  embeds_many :comments
  index :created_at

  field :parent_id
  field :ancestor_id
  index :ancestor_id
  field :private, type: Boolean, default: false
  field :import, type: Boolean, default: false
  field :repost_count, type: Integer, default: 0
  field :favor_count, type: Integer, default: 0
  field :tags, type: Array, default: []
  index :tags

  attr_accessible :blog, :author, :author_id, :blog_id, :created_at, :comments, :parent, :tags, :private

  validates_presence_of :author_id
  validates_presence_of :blog_id, :message => "请选择要发布到的页面"

  validate :posted_to_editable_blogs, :if => :new_record?

  before_destroy :clean_comments_notices
  before_create :type_setter, :private_setter
  after_create :ancestor_reposts_inc, :parent_reposts_inc, :update_blog, :push_to_clients

  scope :all_by_updated, desc(:updated_at)
  scope :pics_and_text, where(:_type.in => ["Text", "Pics"], :private.ne => true)
  scope :tagged, ->(tag) { where(:tags => tag, :private.ne => true).desc(:created_at) }
  scope :in_day, ->(date) { where(:created_at.gte => date.midnight,
                                  :created_at.lte => date.end_of_day).desc(:created_at) }
  scope :author, ->(user) { where(author_id: user.id) }
  scope :subs, ->(user) do
    sub_id_list = user.all_blogs.reduce [], do |list, blog|
      if blog.open_to?(user) then list << blog.id else list end
    end
    where({:blog_id.in => sub_id_list})
  end
  scope :publics, ->(page) { where(:private.ne => true).desc(:created_at).page(page) }

  #for sphinx indexing
  def blog_num_id
    blog.num_id
  end

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
    Post.all.for_ids(parent_id).first unless parent_id.nil?
  end

  def ancestor
    return nil if ancestor_id.nil?
    Post.all.for_ids(ancestor_id).first || parent
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

    def news(page)
      Blog.latest.page(page).reduce([]) do |posts, b|
        post = b.posts.desc(:created_at).limit(1).first
        posts << post if not post.nil? and post.created_at == b.posted_at
        posts
      end
    end

    def news_channel
      "/news"
    end

    def wall
      Blog.latest.limit(200).sample(50).reduce([]) do |posts, b|
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

    #for sphinx stream (xmlpipe2 output), no cursor timeout
    def sphinx_stream_no_timeout
      #Real stream
      STDOUT.sync = true

      # Schema
      puts <<EOF
<?xml version="1.0" encoding="utf-8"?>
<sphinx:docset>
<sphinx:schema>
<sphinx:field name="classname"/>
<sphinx:field name="title"/>
<sphinx:field name="tags"/>
<sphinx:field name="content"/>
<sphinx:attr name="_id" type="string" />
<sphinx:attr name="private" type="bool"/>
<sphinx:attr name="blog_num_id" type="int"/>
</sphinx:schema>
EOF

      # Documents
      Post.collection.db['posts'].find({}, timeout: false) do |cursor|
        cursor.each do |document|
          if document['title'].blank? and document['content'].blank? and document['tags'].blank?
            next
          end

          puts <<EOF
<sphinx:document id="#{self.generate_id(document['_id'])}">
<classname>#{self.to_s}</classname>
EOF
          puts "<title>#{document['title'].to_xs}</title>" unless document['title'].blank?
          puts "<tags>#{document['tags'].to_s.to_xs}</tags>" unless document['tags'].blank?
          puts "<content>#{document['content'].to_xs}</content>" unless document['content'].blank?
          
          puts <<EOF
<_id>#{document['_id']}</_id>
<private>#{document['private'] ? 1 : 0}</private>
<blog_num_id>#{document['blog_id'].to_s[0...8].hex}</blog_num_id>
</sphinx:document>
EOF
        end
      end

      puts '</sphinx:docset>'
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

  def muted_by?(user)
    not user.nil? and user.mutings.where(:post_id => id).count > 0
  end

  def notify_watchers(comment)
    watchers = self.watchers
    watchers.delete comment.author
    watchers.each do |w|
      w.insert_unread_comments_notices!(self)
    end
  end

  def watchers
    watchers =  comments.map {|f| f.author}
    watchers << author
    watchers.uniq.reject {|user| self.muted_by?(user)}
  end

  def stripped_content
    require 'filters/tag_stripper'
    TagStripper.filter self.content
  end

  def repost_count_all
    if ancestor
      ancestor.repost_count
    else
      repost_count
    end
  end

  def repost_history
    return nil unless repost_count_all && repost_count_all >= 1
    Post.desc(:created_at).
      where(:ancestor_id => (ancestor.nil? ? id : ancestor.id)).
      limit(30)
  end

  def favors
    return User.where('favors.post_id' => id).limit(50) if favor_count > 0
  end

  private

  def update_blog
    blog.update_attributes(:posted_at => created_at)
    blog.handle_sync(self) unless import?
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

  def parent_reposts_inc
    unless parent.nil? || parent == ancestor
      if parent.repost_count.nil?
        parent.update_attributes(:repost_count => 1)
      else
        parent.inc :repost_count, 1
      end
    end
  end

  def push_to_clients
    return if private? or import?
    channels = User.where("followings.blog_id" => blog.id).map { |u| u.home_channel }
    channels << Post.news_channel
    push_to_comet(channels, post_id: id, blog_id: blog.id)
  end
end
