class ImagesController < ApplicationController
  def create
    file_io = params[:file]
    @image = Image.create_from_original file_io

    render :json => {
      :o => @image.url_for(:original),
      :id => @image._id
    }
  end

  def new
  end
end
