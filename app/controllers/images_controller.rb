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
    process = PROCESS_SPEC[params[:type].to_sym]
    begin
      @image = Image.create_from_original file_io, process
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
      image: @image.to_hash
    }.to_json
  end
end
