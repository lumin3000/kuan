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
    return @extra[:controller].render_to_string 'comments/index', :layout => false
  end

  expose :@post, :type

  def url
    @extra[:base_url] + "posts/#{@post.id}" if @extra.has_key? :base_url
  end

  def repost_tag
    return '' if @extra[:current_user].nil?
    Proc.new do |text|
      <<CODE.html_safe
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
end
