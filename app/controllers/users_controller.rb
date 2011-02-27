# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :signin_auth, :only => [:show, :edit, :update, :followings]
  before_filter :signup_auth, :only => [:new, :create]

  def new
    @user = User.new
    render :layout => "user"
  end

  def create
    @user = User.new params[:user]
    return (render 'new', :layout => "user") if !@user.save

    @user.create_primary_blog!
    @inv_user.blogs.each {|b| @user.follow! b}

    sign_in @user
    flash[:success] = "欢迎注册"
    redirect_to home_path
  end

  #param :uri: 显示指定uri的blog的信息和帖子列表，否则使用默认页面
  def show
    @blog = @user.primary_blog
    @blogs = @user.blogs
    pagination = {
      :page => params[:page] || 1,
      :per_page => 2,
    }
    if !params[:uri].blank?
      param_blog = Blog.where(:uri => params[:uri]).first
      @blog = @user.blogs.include?(param_blog) ? param_blog : @blog
      cond = {:blog_id => @blog.id}
      @at_dashboard = false
    else
      cond = {:blog_id.in => @blogs.map {|b| b.id}}
      @at_dashboard = true
    end
    @posts = Post.paginate pagination.update({:conditions => cond})
  end

  def edit
    render :layout => "account"
  end

  def update
    if @user.update_attributes params[:user]
      flash[:success] = "账户信息更新成功"
      redirect_to home_path
    else
      render 'edit', :layout => "account"
    end
  end

  def followings
    @blogs = @user.subs
    render :layout => "blogs"
  end

  private

  def signup_auth
    return render 'invalid_invitation' if params[:code].blank?
    @inv_user = User.find_by_code params[:code]
    return render 'invalid_invitation' if @inv_user.nil?
  end
end
