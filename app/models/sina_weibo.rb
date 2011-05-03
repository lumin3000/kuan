# encoding: utf-8

class SinaWeibo < OAuthTarget
  require 'json'
  require 'curb'
  require 'uri'
  SITE = 'http://api.t.sina.com.cn/'

  class << self
    def consumer_key
      '609051831'
    end

    def consumer_secret
      'debf621a6f856f9cd08b855522bdb2a1'
    end

    def after_auth(target, access_token)
      response = access_token.get '/account/verify_credentials.json'
      response = JSON.load response.body
      target.account = response['name']
    end
  end

  def self.site
    SITE
  end

  def self.grid
    @grid ||= Mongo::Grid.new self.db
  end

  def handle_text(post)
    text = post.title.blank? ? post.stripped_content : post.title
    status = compose_status(text, post)
    update_status status
  end

  def handle_pics(post)
    photo = post.photos.first
    image = grid.get photo.image.large
    damned_upload "#{SITE}statuses/upload.json",
      :pic => image,
      :status => compose_status(photo.desc, post)
  end

  def handle_link(post)
    shared_url = post.url
    text = post.title || ''
    status = shared_url + ' ' + compose_status(text, post, -10)
    update_status status
  end

  def handle_video(post)
    video_url = post.url
    text = post.stripped_content || ''
    status = video_url + ' ' + compose_status(text, post, -10)
    update_status status
  end

  def grid
    self.class.grid
  end

  def update_status(status)
    access_token.post "#{SITE}statuses/update.json", :status => status
  end

  LIMIT = 100
  private
  def compose_status(text, post, limit_delta=0)
    limit = LIMIT + limit_delta
    url = compose_url(post)
    [text.truncate(limit - 1), '宽岛-' + post.blog.title.to(15), url].join ' '
  end

  def damned_upload(url, params)
    parsed_url = URI.parse url
    fake_request = Net::HTTP::Post.new url
    fake_params = params.reject{|k, v| k == :pic}
    fake_request.set_form_data fake_params
    fake_request['Content-Type'] = 'application/x-www-form-urlencoded'
    at = self.access_token
    at.sign! fake_request, :request_uri => url, :parameters => fake_params

    actual_request = Curl::Easy.new url
    actual_request.multipart_form_post = true
    actual_request.headers['Authorization'] = fake_request['Authorization']
    fields = params.map do |k, v|
      if k == :pic
        Curl::PostField.file k.to_s, v.server_md5.to_s do |f|
          f.content_type = v.content_type
          v.read
        end
      else
        Curl::PostField.content k.to_s, v
      end
    end
    actual_request.http_post(*fields)
    actual_request
  end

  def on_request_error(res_body)
    self.destroy if res_body.include? '40072'
  end
end

# Make it compatible with Net::HTTP
module Curl
  class Easy
    alias_method :body, :body_str
    def code
      response_code.to_s
    end
  end
end
