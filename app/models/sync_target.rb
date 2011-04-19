module SyncTarget
  class SinaWeibo
    require 'oauth'
    require 'net/http'
    require 'net/http/post/multipart'

    include Mongoid::Document
    referenced_in :blog

    field :status, :type => Symbol, :default => :waiting_for_auth
    field :token_key
    field :token_secret

    CONSUMER_KEY = '609051831'
    CONSUMER_SECRET = 'debf621a6f856f9cd08b855522bdb2a1'
    SITE = 'http://api.t.sina.com.cn/'

    def self.apply(blog, controller)
      request_token = consumer.get_request_token
      if create( :token_key => request_token.token,
                :token_secret => request_token.secret,)
        callback_url = controller.blog_path(blog) + 'sync_callback/sina_weibo'
        controller.redirect_to request_token.authorize_url(
          :oauth_callback => callback_url)
      else
        controller.render :status => 500
      end
    end

    def self.consumer
      @consumer ||= OAuth::Consumer.new CONSUMER_KEY, CONSUMER_SECRET,
        :site => SITE
    end
  end
end
