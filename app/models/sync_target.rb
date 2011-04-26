class SyncTarget
  include Mongoid::Document
  referenced_in :blog

  private
  def compose_url(post)
    # Yeah I confess this is a dirty hack
    "http://#{post.blog.uri}.kuandao.com/posts/#{post.id.to_s}"
  end
end
