# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    return render 'new' if !@user.save
    flash[:success] = "欢迎注册"
    redirect_to home_path
  end

  def show 
  end
 
end
