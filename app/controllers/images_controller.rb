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
    @image = Image.create_from_original file_io, process

    render :text => @image.to_json
  end
end
