require 'net/http'
require 'nokogiri'
require 'cgi'
require 'json'
require 'mongo'

class Mover

  def initialize
    @kdb = Mongo::Connection.new.db("ktd")
    @fs = Mongo::Grid.new(@kdb)
    @grid = Mongo::GridFileSystem.new(@kdb)
    @cookie = login
    @posts = @kdb["posts"]
  end

  def login
    url = URI.parse('http://www.kuantu.com/login')
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({'useremail' => 'kuantu.web@gmail.com',
                        'userpassword' => 'vagaa.com'})
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      res['set-cookie'].split(', ').map {|c| c.split('; ')[0]}.join('; ')
    else
      res.error!
    end
  end

  def moving=(moving)
    @moving = moving
    @from_uri = moving.from_uri
    m = /^http:\/\/([a-z0-9]+)\.kuantu\.com$/.match @from_uri
    @from = m[1]
  end

  def fetch_img(hashid)
    hashid = encry_img(hashid)
    return if @kdb["fs.files"].find_one(:filename=>hashid)
    k = 0
    begin
      Net::HTTP.start('img.kuantu.com') do |http|
        http.open_timeout = http.read_timeout = 10
        res,body = http.get '/files/'+hashid+'/o'
        case res
        when Net::HTTPSuccess
          @fs.put(body, {:filename=>hashid})
        else
          Rails.logger.info "fetch_img  #{hashid} failed!"
        end
      end
    rescue Exception => e
      retry if (k+=1) <= 3
      Rails.logger.info "fetch_img  #{hashid} #{e}"
    end
  end

  def fetch_post(id,type,c)
    begin
      case type
      when 1
        c
      when 2
        c = JSON c
        c["photos"].each do |photo|
          fetch_img photo["photo_url"]["o"].split('.')[0]
        end
        c
      else
        JSON c
      end
    rescue JSON::ParserError => e
      nil
    end
  end

  def fetch_by_time(time)
    k = 0
    begin
      url = URI.parse("#{@from_uri}/rss/pubtime/#{time}")
      req = Net::HTTP.new(url.host, url.port)
      req.open_timeout = req.read_timeout = 10
      headers = {"Cookie" => @cookie}
      res, body = req.get(url.path, headers)
    rescue Exception => e
      retry if (k+=1) <= 3
      Rails.logger.info "fetch_by_time #{@from} time #{time} #{e}"
    end
    case res
    when Net::HTTPSuccess
      doc = Nokogiri::HTML body
      Rails.logger.info "doc #{url} "+doc.xpath('//item').length.to_s
      doc.xpath('//item').each do |item|
        id = item.at_xpath('postid').text.to_i
        type = item.at_xpath('resourcetype').text.to_i
        rawpost = item.at_xpath('rawpost').text
        pubtime = item.at_xpath('rawpubtime').text.to_i
        email = item.at_xpath('rawemail').text
        content = fetch_post id,type,rawpost
        post = {
          :uri => @from,
          :pubtime => pubtime,
          :email => email,
          :type => type,
          :post => content,
          :postid => id
        }

        @posts.insert post
        time = post[:pubtime] if post[:pubtime] >= time
      end
      fetch_by_time(time) unless  doc.xpath('//item').length < 10
    else
      Rails.logger.info "fetch_by_time uri #{@from} time #{time} failed!"
    end
  end

  def fetch
    Rails.logger.info "Fetch from #{@from}:"
    last = @posts.find_one({"uri"=>@from},:sort=>["pubtime",:desc])
    fetch_by_time((last)?last["pubtime"]:1)
  end

  def encry_img(hashid)
    hashid + Digest::MD5.hexdigest(hashid+"feixueliantianshebailu")[16..19]
  end

  def trans_pics(pics)
    pics_new = Pics.new(:content => pics["desc"])
    pics["photos"].each do |p|
      photo_new = Photo.new(:desc => p["desc"])
      @grid.open(encry_img(p["photo_url"]["o"].split('.').first), 'r') do |f|
        photo_new.image = Image.create_from_original(f,
                                                   {
                                                     :large => [500, 0],
                                                     :medium => [180, 300],
                                                     :small => [60, 60],
                                                   })
      end
      pics_new.photos << photo_new
    end
    pics_new
  end

  def trans_post(post)
    Rails.logger.info "Trans #{post['postid']} #{post['type']}"
    post_new = case post["type"]
               when 1
                 Text.new(:content => post["post"])
               when 2
                 trans_pics post["post"]
               when 3
                 Text.new(:title => post["post"]["title"],
                          :content => post["post"]["content"])
               when 4
                 Link.new(:title => post["post"]["title"],
                          :url => post["post"]["url"],
                          :content => post["post"]["desc"])
               when 5
                 Video.new(:content => post["post"]["desc"],
                           :url => post["post"]["src"],
                           :thumb => post["post"]["img"],
                           :site => post["post"]["from"])
               else
                 nil
               end
    return if post_new.nil?
    post_new.blog = Blog.find_by_uri! @moving.to_uri
    post_new.author = @moving.user
    post_new.created_at = Time.at(post["pubtime"]).utc
    return unless post_new.valid?
    post_new.save
  end

  def trans
    trans_cur = @moving.trans_cur
    Rails.logger.info "Trans from #{trans_cur}"
    @posts.find({"uri"=>@from, "postid"=>{"$gt" => trans_cur}}, :sort=>["postid", :asc]).each do |post|
      begin
        trans_post post
      rescue Exception => e
      end
      trans_cur = post["postid"]
    end
    Rails.logger.info "Trans to #{trans_cur}"
    moving = Moving.where(:from_uri => @from_uri, :to_uri => @moving.to_uri).first
    moving.trans_cur = 2
    moving.save!
  end

  class << self
    def run
      mover = Mover.new
      Moving.asc(:created_at).each do |moving|
        mover.moving = moving
        mover.fetch
        mover.trans
      end
    end
  end
end
