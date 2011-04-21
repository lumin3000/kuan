class SinaWeibo < SyncTarget
  # FIXME: extract oauth logic to a new super class
  require 'oauth'
  require 'net/http'
  require 'net/http/post/multipart'
  require 'json'

  field :status, :type => Symbol, :default => :waiting_for_auth
  field :token_key
  field :token_secret
  field :account

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
    response = access_token.get '/account/verify_credentials.json'
    response = JSON.load response.body
    target.account = response['name']
    target.token = access_token
    target.status = :verified
    if target.save
      controller.render 'sync/setup_success', :layout => false
    else
      controller.render :status => 500
    end
  end

  def self.consumer
    @consumer ||= OAuth::Consumer.new CONSUMER_KEY, CONSUMER_SECRET,
      :site => SITE
  end

  def self.grid
    @grid ||= Mongo::Grid.new self.db
  end

  def token=(token)
    self.token_key = token.token
    self.token_secret = token.secret
  end

  def request_token
    OAuth::RequestToken.new self.consumer, token_key, token_secret
  end

  def access_token
    @access_token ||= OAuth::AccessToken.new self.consumer, token_key, token_secret
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
    text = post.title.blank? ? post.stripped_content : post.title
    # Yeah I confess this is a dirty hack
    url = "http://#{post.blog.uri}.kuandao.com/posts/#{post.id.to_s}"
    status = compose_status(text, url)
    access_token.post "#{SITE}statuses/update.json", :status => status
  end

  def handle_pics(post)
    raise NotImplementedError
    photo = post.photos.first
    text = photo.desc[0...140]
    image_id = photo.image.original
    image = grid.get image_id
    request = Net::HTTP::Post::Multipart.new "#{SITE}statuses/upload.json",
      :pic => UploadIO.new(image, image.content_type, image_id.to_s),
      :status => text
  end

  def handle_link(post)
    raise NotImplementedError
  end

  def handle_video(post)
    raise NotImplementedError
  end

  def grid
    self.class.grid
  end

  private
  def compose_status(text, url)
    case text.size
    when 0
      url
    when 1...120
      text + ' ' + url
    else
      text[1...120] + '... ' + url
    end
  end
end
