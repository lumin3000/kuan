class ImagesController < ApplicationController
  def create
    file_io = params[:file]
    @image = Image.create_from_original file_io
  end

  def new
  end
end
