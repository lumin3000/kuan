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
    <<EOF.html_safe
  <iframe border=0 width='594px' scrolling=NO style="overflow-x: hidden; overflow-y: scroll" src="#{self.url_for_comments}"></iframe>
EOF
  end

  expose :@post, :type

  def url
    @extra[:base_url] + "post/#{@post.id}" if @extra.has_key? :base_url
  end

  def url_for_comments
    (@extra[:url_template] % 'www') + "posts/#{@post.id}/comments" if @extra.has_key? :url_template
  end

  def comments_count
    @post.comments.count
  end
end
