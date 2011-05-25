class Douban < OAuthTarget
  require 'net/http'
  require 'filters/tag_stripper'
  require 'nokogiri'

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
    # Here be dragons.
    at = target.access_token
    request = Net::HTTP::Get.new '/people/@me'
    at.sign! request, :request_uri => 'http://api.douban.com/people/%40me'
    response = Net::HTTP.start 'api.douban.com', 80 do |con|
      con.request(request)
    end
    raise response.body.force_encoding("utf-8") unless response.code == '200'
    response_xml = Nokogiri::XML::Document.parse response.body.force_encoding('utf-8')
    target.account = response_xml.css('title').first.content
  end

  def handle_text(post)
    url = compose_url(post)
    title = post.title.blank? ? post.blog.title : post.title
    post_request(url, title, post.stripped_content)
  end

  def handle_pics(post)
    url = compose_url(post)
    post_request(url, post.blog.title)
  end

  def handle_video(post)
    content = post.stripped_content
    title = content.blank? ? post.blog.title : content
    post_request(post.url, title)
  end

  def handle_link(post)
    title = post.title.blank? ? post.blog.title : post.title
    post_request(post.url, title, post.stripped_content)
  end

  def handle_audio(post)
    url = compose_url(post)
    title = "#{post.song_name} - #{post.artist_name}"
    post_request(url, title, post.stripped_content)
  end

  def access_token
    return @access_token if @access_token
    hacked_consumer = consumer.dup
    hacked_consumer.options = consumer.options.dup
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
