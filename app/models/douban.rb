class Douban < OAuthTarget
  class << self
    def consumer_key
      '08b2b7c2a1f29dd81a182747e5d7d988'
    end

    def consumer_secret
      'e36730d42a5788d4'
    end

    def consumer
      @consumer ||= ::OAuth::Consumer.new(consumer_key, consumer_secret,
        :request_token_path => '/service/auth/request_token',
        :authorize_path => '/service/auth/authorize',
        :access_token_path => '/service/auth/access_token',
        :site => site,
        # realm is a must-have field for douban, WTF?
        :realm => 'http://www.kuandao.com'
       )
    end
  end

  SITE = 'http://www.douban.com/'
  def self.site
    SITE
  end

  def self.after_auth(target, access_token)
    target.account = 'test'
  end
end
