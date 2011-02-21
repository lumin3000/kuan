class PostsController < ApplicationController

  def new
    @type = params[:type] || Post.subclasses.first.name.downcase!
    @post = Post.infer_type(@type).new
    @post[:_type] = @type
  end

  def create
    @post = Post.infer_type(params[:_type]).new(params)
    respond_to do |format|
      if @post.save
        format.js
      else
        render :action => 'new'
      end
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    respond_to do |format|
      if @post.update_attributes(params)
        format.js
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.js
    end
  end
end
