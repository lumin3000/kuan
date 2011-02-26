# -*- coding: utf-8 -*-
class BlogsController < ApplicationController
  before_filter :signin_auth, :except => [:show]
  before_filter :custom_auth, :only => [:edit, :update]
  before_filter :find_by_uri,
    :only => [:followers, :follow_toggle]

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new params[:blog]
    return render 'new' if !@blog.save

    current_user.follow! @blog, "founder"

    flash[:success] = "#{@blog.title} 已成功创建 "
    redirect_to home_path
  end

  def edit
  end

  def update
    if @blog.update_attributes params[:blog]
      flash[:success] = "页面信息更新成功"
      redirect_to home_path
    else
      render 'edit'
    end
  end

  def show
    find_by_uri request.subdomain
    render '404', :status => 404 and return if @blog.nil?
    post_id = params[:post_id]
    if post_id.nil?
      @posts = Post.paginate({
        :conditions => {:blog_id => @blog.id},
        :page => params[:page] || 1,
        :per_page => 2,
      })
    else
      @posts = [Post.find(post_id)]
    end
    render :layout => false
  end

  def followers
    @followers = @blog.followers
  end

  def follow_toggle
    redirect_to home_path if @blog.nil?
    follow?(@blog) ? @user.unfollow!(@blog) : @user.follow!(@blog)
    redirect_to blog_path, :uri => @blog.uri
  end

  private

  def custom_auth
    find_by_uri
    redirect_to home_path unless custom_auth? @blog
  end

  def find_by_uri(uri = nil)
    @blog = Blog.find_by_uri!(uri || params[:id])
  end
end
