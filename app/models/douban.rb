class Douban < OAuthTarget
  require 'net/http'
  require 'filters/tag_stripper'

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

  def handle_text(post)
    url = compose_url(post)
    post_request(url, post.title, post.content)
  end

  def handle_pics(post)
    url = compose_url(post)
    post_request(url)
  end

  def handle_video(post)
    post_request(post.url, post.content)
  end

  def handle_link(post)
    post_request(post.url, post.title, post.content)
  end

  def access_token
    return @access_token if @access_token
    hacked_consumer = consumer.dup
    hacked_consumer.options[:site] = 'http://api.douban.com/'
    @access_token = OAuth::AccessToken.new hacked_consumer, token_key, token_secret
  end

  require 'cgi'
  private
  def h(str)
    return '' if str.nil?
    CGI.escapeHTML(str)
  end

  def post_request(url, title = '', text =  '')
    text = TagStripper.filter(text).truncate(120)
    title = TagStripper.filter(title).truncate(40)
    # Do we have to load all the GData library?
    xml_entry = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
  xmlns:gd="http://schemas.google.com/g/2005"
  xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/"
  xmlns:db="http://www.douban.com/xmlns/">
  <title>#{h title}</title>
  <db:attribute name="comment">#{h text}</db:attribute>
  <link href="#{h url}" rel="related" />
</entry>
EOF
    request = Net::HTTP::Post.new '/recommendations'
    request.body = xml_entry
    request['Content-Length'] = xml_entry.bytesize
    request['Content-Type'] = 'application/atom+xml; charset=utf-8'
    access_token.sign! request
    Net::HTTP.start 'api.douban.com', 80 do |con|
      con.request(request)
    end
  end
end
