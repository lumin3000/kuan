# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    return render 'new' if !@user.save
    sign_in @user
    flash[:success] = "欢迎注册"
    redirect_to home_path
  end

  def show
    return redirect_to signin_path if !signed_in?
  end
 
end
