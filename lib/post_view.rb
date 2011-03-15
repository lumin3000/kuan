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
    @post.created_at
  end

  def load_comments
    return (load_js +
      @extra[:controller].render_to_string('comments/index', :layout => false)).html_safe
  end

  expose :@post, :type

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

  def comments_count
    @post.comments.count
  end

  def parent
    ObjectView.wrap @post.parent.blog, @extra
  end

  def repost
    true
  end
end
