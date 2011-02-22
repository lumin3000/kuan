class ImagesController < ApplicationController
  PROCESS_SPEC = {
    photo: {
      large: [500, 800],
      medium: [180, 300],
      small: [60, 60],
    }
  }

  PROCESS_SPEC.default = {}

  def create
    file_io = params[:file]
    process = PROCESS_SPEC[params[:type].to_sym]
    @image = Image.create_from_original file_io, process

    render :text => {
      :o => @image.url_for(:original),
      :id => @image._id
    }.to_json
  end
end
