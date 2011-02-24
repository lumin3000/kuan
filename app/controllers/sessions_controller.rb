# -*- coding: utf-8 -*-
class SessionsController < ApplicationController
  layout "user"
  def new
  end

  def create
    user, error = User.authenticate(params[:session][:email],
                                    params[:session][:password])
    if error
      case error
      when :email
        flash.now[:email_error] = "此邮箱地址还未注册，请重新输入"
      when :password
        flash.now[:password_error] = "密码错误，请重新输入"
      end
      return render 'new'
    end

    sign_in user
    redirect_back_or home_path
  end

  def destroy
    sign_out 
    redirect_to signin_path
  end

end
