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

  expose :@post, :type

  def url
    @extra[:base_url] + "post/#{@post.id}" if @extra.has_key? :base_url
  end

  def url_for_comments
    (@extra[:url_template] % 'www') + "posts/#{@post.id}/comments" if @extra.has_key? :url_template
  end

end
