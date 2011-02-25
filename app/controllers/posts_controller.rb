# encoding: utf-8

class PostsController < ApplicationController
  before_filter :signin_auth

  def new
    @type = params[:type] || Post.default_type
    @post = Post.infer_type(@type).new
    @post.type = @type
    get_target_blogs
  end

  def create
    type = params.delete :type
    @post = Post.infer_type(type).new(params)
    respond_to do |format|
      if !@post.error && @post.save
        format.js
      else
        Rails.logger.debug @post.errors
        format.js do
          render :text => "console.log(#{@post.errors.to_json})"
        end
      end
    end
  end

  def edit
    @post = Post.find(params[:id])
    if not @post.editable_by? @user
      render :status => :forbidden, :text => "放开那帖子"
    end
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
    if not @post.editable_by? @user
      render :status => :forbidden, :text => "放开那帖子"
      return
    end
    @post.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def get_target_blogs
    @target_blogs = @user.blogs
  end
end
