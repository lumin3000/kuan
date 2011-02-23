# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :signin_auth, :only => [:show, :edit, :update, :followings]

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    return render 'new' if !@user.save

    @user.create_primary_blog!
    sign_in @user 
    flash[:success] = "欢迎注册"
    redirect_to home_path
  end

  #param :uri: 显示指定uri的blog的信息和帖子列表，否则使用默认页面
  def show
    @blog = @user.blogs.first
    if !params[:uri].blank?
      param_blog = Blog.where(:uri => params[:uri]).first
      @blog = @user.blogs.include?(param_blog) ? param_blog : @blog
    end
  end

  def edit
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
 
end
