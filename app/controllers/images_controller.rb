# encoding: utf-8

class ImagesController < ApplicationController
  PROCESS_SPEC = {
    photo: {
      large: [500, 0],
      medium: [180, 300],
      small: [60, 60],
    },
    blog_icon: {
      large: [180, 180],
      medium: [60, 60],
      small: [24, 24],
    },
    template_thumbnail: {
      small: [200, 120],
    },
  }

  PROCESS_SPEC.default = {}

  def create
    file_io = params[:file]
    filename = file_io.blank? ? '' : file_io.original_filename
    url = params[:url]
    process = PROCESS_SPEC[params[:type].to_sym]
    begin
      if file_io
        @image = Image.create_from_original file_io, process
      elsif url
        @image = Image.create_from_url url, process
      else
        render :text => {
          status: "error",
          message: "参数错误" }.to_json
        return
      end
    rescue Exception => e
      Rails.logger.error e
      render :text => {
        status: "error",
        message: e.message
      }.to_json
      return
    ensure
      file_io.close if file_io.respond_to? :close
    end

    render :text => {
      status: "success",
      image: @image.to_a_fucking_hash('/' + filename)
    }.to_json
  end

  def upload_log
    logger = Logger.new("#{Rails.root.to_s}/log/image_upload.log")
    email = current_user.nil? ? "nologin" : current_user.email
    logger.info %(#{Time.now} : #{request.remote_ip} : #{email} : #{params[:info]})
    render :text => "logged"
  end
end
