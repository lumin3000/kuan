# encoding: utf-8

class SinaWeibo < SyncTarget
  # FIXME: extract oauth logic to a new super class
  require 'oauth'
  require 'net/http'
  require 'net/http/post/multipart'
  require 'json'
  require 'uri'

  field :status, :type => Symbol, :default => :waiting_for_auth
  field :token_key
  field :token_secret
  field :account

  CONSUMER_KEY = '609051831'
  CONSUMER_SECRET = 'debf621a6f856f9cd08b855522bdb2a1'
  SITE = 'http://api.t.sina.com.cn/'

  def self.apply(blog, controller)
    blog.sync_targets.each do |t|
      t.destroy if t.class == self
    end

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

  def self.logger
    @logger ||= Logger.new 'log/sync.log'
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
    return unless self.respond_to? method
    begin
      response = self.send method, post
      raise response.body unless response.code == '200' || response.code == '304'
    rescue Exception => e
      self.class.logger.info e.to_s.force_encoding('utf-8')
    end
  end

  def handle_text(post)
    text = post.title.blank? ? post.stripped_content : post.title
    url = compose_url(post)
    status = compose_status(text, url)
    update_status status
  end

  def handle_pics(post)
    photo = post.photos.first
    url = compose_url(post)
    image_id = photo.image.original
    image = grid.get image_id
    damned_upload "#{SITE}statuses/upload.json",
      :pic => UploadIO.new(image, image.content_type, image_id.to_s),
      :status => url
  end

  def handle_link(post)
    shared_url = post.url
    url = compose_url(post)
    text = post.title || ''
    status = shared_url + ' ' + compose_status(text, url, 110)
    update_status status
  end

  def handle_video(post)
    video_url = post.url
    text = post.content || ''
    url = compose_url(post)
    status = video_url + ' ' + compose_status(text, url, 110)
    update_status status
  end

  def grid
    self.class.grid
  end

  def update_status(status)
    access_token.post "#{SITE}statuses/update.json", :status => status
  end

  private
  def compose_status(text, url, limit = 120)
    text.truncate(limit - 1) + ' 来自:' + url
  end

  def compose_url(post)
    # Yeah I confess this is a dirty hack
    "http://#{post.blog.uri}.kuandao.com/posts/#{post.id.to_s}"
  end

  def damned_upload(url, params)
    parsed_url = URI.parse url
    fake_request = Net::HTTP::Post.new url
    fake_params = params.reject{|k, v| k == :pic}
    fake_request.set_form_data fake_params
    fake_request['Content-Type'] = 'application/x-www-form-urlencoded'
    at = self.access_token
    at.sign! fake_request, :request_uri => url, :parameters => fake_params

    actual_request = Net::HTTP::Post::Multipart.new url, params
    actual_request['Authorization'] = fake_request['Authorization']
    Net::HTTP.start parsed_url.host, parsed_url.port do |con|
      con.request(actual_request)
    end
  end
end

# Monkey patched for multipart-post
module Mongo
  class GridIO
    alias_method :length, :file_length

    def path
    end
  end
end
