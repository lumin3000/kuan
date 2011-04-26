# encoding: utf-8

class SinaWeibo < OAuthTarget
  require 'json'
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
