class OAuthTarget < SyncTarget
  require 'oauth'
  require 'net/http'
  require 'net/http/post/multipart'
  require 'uri'

  field :status, :type => Symbol, :default => :waiting_for_auth
  field :token_key
  field :token_secret
  field :account

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
    after_auth(target, access_token)
    target.token = access_token
    target.status = :verified
    if target.save
      controller.render 'sync/setup_success', :layout => false
    else
      controller.render :status => 500
    end
  end

  def self.after_auth(target, access_token)
    nil
  end

  def self.consumer
    @consumer ||= OAuth::Consumer.new consumer_key, consumer_secret,
      :site => site
  end

  def self.apply(blog, controller)
    blog.sync_targets.each do |t|
      t.destroy if t.class == self
    end

    begin
      request_token = consumer.get_request_token
    rescue Exception => e
      raise e
    end
    if create( :token_key => request_token.token,
              :token_secret => request_token.secret,
              :blog_id => blog.id)
      callback_url = controller.blog_path(blog) + 'sync_callback/' + self.name.underscore
      controller.redirect_to request_token.authorize_url(
        :oauth_callback => callback_url)
    else
      controller.render :status => 500
    end
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
      raise response.body if response.code[0] == '4'
    rescue Exception => e
      self.class.logger.info e.to_s.force_encoding('utf-8')
    end
  end
end
