class ImagesController < ApplicationController
  def create
    file_io = params[:file]
    @image = Image.create_from_original file_io

    render :text => {
      :o => @image.url_for(:original),
      :id => @image._id
    }.to_json
  end

  def new
  end
end
