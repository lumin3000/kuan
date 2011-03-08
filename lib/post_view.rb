class PostView
  extend Forwardable
  include ObjectView

  def initialize(post, extra = {})
    @post = post
    @extra = extra
  end

  def author
    ObjectView.wrap(@post.author, @extra)
  end

  def_delegator :@post, :created_at, :create_date
  expose :@post, :type

  def url
    @extra[:base_url] + "post/#{@post.id}"
  end

  def url_for_comments
    (@extra[:url_template] % 'www') + "posts/#{@post.id}/comments"
  end

end
