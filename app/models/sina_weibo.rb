class SinaWeibo < SyncTarget
  # FIXME: extract oauth logic to a new super class
  require 'oauth'
  require 'net/http'
  require 'net/http/post/multipart'

  field :status, :type => Symbol, :default => :waiting_for_auth
  field :token_key
  field :token_secret

  CONSUMER_KEY = '609051831'
  CONSUMER_SECRET = 'debf621a6f856f9cd08b855522bdb2a1'
  SITE = 'http://api.t.sina.com.cn/'

  def self.apply(blog, controller)
    request_token = consumer.get_request_token
    if create( :token_key => request_token.token,
              :token_secret => request_token.secret,
              :blog_id => blog.id)
      callback_url = controller.blog_path(blog) + 'sync_callback/sina_weibo'
      controller.redirect_to request_token.authorize_url(
        :oauth_callback => callback_url)
    else
      controller.render :status => 500
    end
  end

  def self.auth(blog, controller)
    target = where(:blog_id => blog.id,
                          :token_key => controller.params[:oauth_token]).first
    unless target
      controller.render :status => 404
      return
    end

    access_token = target.request_token.get_access_token(
      :oauth_verifier => controller.params[:oauth_verifier])
    unless access_token
      controller.render :status => 400
      return
    end
    target.token = access_token
    target.status = :verified
    if target.save
      controller.render :text => 'sync setup success!'
    else
      controller.render :status => 500
    end
  end

  def self.consumer
    @consumer ||= OAuth::Consumer.new CONSUMER_KEY, CONSUMER_SECRET,
      :site => SITE
  end

  def token=(token)
    self.token_key = token.token
    self.token_secret = token.secret
  end

  def request_token
    OAuth::RequestToken.new self.consumer, token_key, token_secret
  end

  def access_token
    OAuth::AccessToken.new self.consumer, token_key, token_secret
  end

  def consumer
    self.class.consumer
  end

  def handle_post(post)
    return unless self.status == :verified
    return if post.class == Post
    method = "handle_#{post.class.name.downcase}"
    self.send method, post if self.respond_to? method
  end

  def handle_text(post)
    status = post.title.empty? ? post.content : post.title
    raise NotImplementedError
  end

  def handle_pics(post)
    raise NotImplementedError
  end

  def handle_link(post)
    raise NotImplementedError
  end

  def handle_video(post)
    raise NotImplementedError
  end
end
