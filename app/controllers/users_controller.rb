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
    return render 'new' if !@user.save

    @user.create_primary_blog!
    @inv_user.blogs.each {|b| @user.follow! b}

    sign_in @user
    flash[:success] = "欢迎注册"
    redirect_to home_path
  end

  #param :uri: 显示指定uri的blog的信息和帖子列表，否则使用默认页面
  def show
    @blog = @user.primary_blog
    if !params[:uri].blank?
      param_blog = Blog.where(:uri => params[:uri]).first
      @blog = @user.blogs.include?(param_blog) ? param_blog : @blog
    end
  end

  def edit
    render :layout => "account"
  end

  def update
    if @user.update_attributes params[:user]
      flash[:success] = "账户信息更新成功"
      redirect_to home_path
    else
      render 'edit'
    end
  end

  def followings
    @blogs = @user.subs
  end

  private

  def signup_auth
    return render 'invalid_invitation' if params[:code].blank?
    @inv_user = User.find_by_code params[:code]
    return render 'invalid_invitation' if @inv_user.nil?
  end
end
