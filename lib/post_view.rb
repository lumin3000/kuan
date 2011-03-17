# encoding: utf-8

class PostView
  include ObjectView

  def initialize(post, extra = {})
    @post = post
    @extra = extra
  end

  def author
    ObjectView.wrap(@post.author, @extra)
  end

  def create_date
    TimeView.new @post.created_at
  end

  def load_comments
    return (load_js +
      @extra[:controller].render_to_string('comments/index', :layout => false)).html_safe
  end

  expose :@post, :type, :favor_count, :repost_count

  def post_type
    type
  end
  def url
    @extra[:base_url] + "posts/#{@post.id}" if @extra.has_key? :base_url
  end

  def repost_tag
    return '' if @extra[:current_user].nil?
    Proc.new do |text|
      <<CODE.html_safe
#{load_js}
<a class="repost" href="#{url}/renew">#{text}</a>
CODE
    end
  end

  def fave_tag
    return '' if @extra[:current_user].nil?
    faved = @post.favored_by?(@extra[:current_user])
    statuses = %w{喜欢 不喜欢}
    classes = %w{faved fave}
    status, reverse_status = faved ? statuses : statuses.reverse
    klass, reverse_klass = faved ? classes : classes.reverse

    Proc.new do |text|
      <<CODE.html_safe
#{load_js}
<a class="#{klass}" data-class="#{reverse_klass}" data-callback="toggle" data-widget="rest"
  data-md="put" data-title="#{status}" title="#{reverse_status}" href="#{url}/favor_toggle">
  #{text}
</a>
CODE
    end
  end

  def is_faved
    fetch_faved
    ! @faved_by.empty?
  end

  def faved_by
    fetch_faved
    @faved_by
  end

  def tags
    @tags = @post.tags.map {|t| TagView.new(t, @extra)} if has_tag
  end

  def has_tag
    !@post.tags.blank?
  end

  def comments_count
    @post.comments.count
  end

  def parent
    ObjectView.wrap @post.parent.blog, @extra if has_repost
  end
  
  def ancestor
    ObjectView.wrap @post.ancestor.blog, @extra if has_repost
  end

  def has_repost
    !@post.parent.nil?
  end

  def repost_count
    if @post.ancestor
      @post.ancestor.repost_count
    else
      @post.repost_count
    end
  end

  private

  def fetch_faved
    @faved_by ||= User.where('favors.post_id' => @post.id).map do |u|
      ObjectView.wrap u,@extra
    end
  end
end
