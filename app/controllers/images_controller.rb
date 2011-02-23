# encoding: utf-8

class ImagesController < ApplicationController
  PROCESS_SPEC = {
    photo: {
      large: [500, 0],
      medium: [180, 300],
      small: [60, 60],
    },
    blog_portrait: {
      large: [180, 180],
      medium: [60, 60],
      small: [24, 24],
    },
  }

  PROCESS_SPEC.default = {}

  def create
    file_io = params[:file]
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
    rescue Execption => e
      logger.error e.message
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
      image: @image.to_a_fucking_hash
    }.to_json
  end
end
