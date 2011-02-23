# -*- coding: utf-8 -*-
class BlogsController < ApplicationController
  before_filter :signin_auth, :except => [:show]
  before_filter :founder_auth, :only => [:edit, :update]

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

  private

  def founder_auth
    @blog = Blog.find params[:id]._id
    if @user.followings.where(:blog_id => @blog._id,
                              :auth => "founder").empty?
      redirect_to home_path
    end
  end

end
