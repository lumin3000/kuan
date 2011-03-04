# -*- coding: utf-8 -*-
class BlogsController < ApplicationController
  before_filter :signin_auth, :except => [:show]
  before_filter :custom_auth, :only => [:edit, :update]
  before_filter :find_by_uri, :only => [:followers, :update]

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
    p = params[:blog]
    p.delete :icon if p[:icon].blank?
    if @blog.update_attributes p
      flash[:success] = "页面信息更新成功"
      redirect_to home_path
    else
      render 'edit'
    end
  end

  def show
    find_by_uri request.subdomain
    render 'shared/404', :status => 404, :layout => false and return if @blog.nil?
    if not @blog.open_to?(current_user)
      render 'shared/403', :status => 403, :layout => false and return
    end
    post_id = params[:post_id]
    @single_post = ! post_id.nil?
    if !@single_post
      @posts = Post.desc(:created_at).where({:blog_id => @blog.id})
        .paginate({
          :page => params[:page] || 1,
          :per_page => 10,
        })

    else
      @posts = [Post.find(post_id)]
      @post = @posts.first
    end
    render :layout => false
  end

  def followers
    @followers = @blog.followers
  end

  def follow_toggle
    @blog = Blog.find params[:id]
    render 'shared/404', :status => 404 and return if @blog.nil?
    if follow?(@blog)
      @user.unfollow!(@blog)
      now_follow = false
    else
      @user.follow!(@blog)
      now_follow = true
    end
    respond_to do |format|
      format.js { @follow = now_follow }
    end
  end

  private

  def custom_auth
    find_by_uri
    redirect_to home_path unless custom_auth? @blog
  end

  def find_by_uri(uri = nil)
    @blog = Blog.find_by_uri!(uri || params[:id] || request.subdomain)
  end
end
