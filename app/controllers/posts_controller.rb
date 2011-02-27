# encoding: utf-8

class PostsController < ApplicationController
  before_filter :signin_auth

  def new
    @type = params[:type] || Post.default_type
    @post = Post.infer_type(@type).new
    @post.type = @type
    get_default_target
    get_target_blogs
  end

  def create
    type = params.delete :type
    @post = Post.infer_type(type).new(params)
    if !@post.error && @post.save
      redirect_to home_path
    else
      get_target_blogs
      @default_target_blog = @post.blog || @user.primary_blog
      return render 'new'
      #Rails.logger.debug @post.errors
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
    if @post.update_attributes(params)
      redirect_to home_path
    else
      return render 'edit'
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if(@post.nil? || !(@post.editable_by? @user))
      render :text => {
        status: "error",
        message: "删除失败"
      }.to_json
      return
    end
    @post.destroy
    render :text => {
      status: "success"
    }.to_json
  end

  private

  def get_target_blogs
    @target_blogs = @user.blogs
    get_default_target
  end


  def get_default_target
    @default_target_blog = if params[:blog_uri].blank?
      @user.primary_blog
    else
      Blog.find_by_uri! params[:blog_uri]
    end
  end
end
