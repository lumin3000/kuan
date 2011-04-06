# -*- coding: utf-8 -*-
module SessionsHelper

  def sign_in(user)
    cookies.permanent.signed[:token] = { :value => [user.id, user.salt], :domain => "."+request.domain}
    current_user = user
  end

  def sign_out
    cookies.delete(:token, :domain => "."+request.domain)
    current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_token
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in?
    !current_user.nil?
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  private

  def user_from_token
    User.authenticate_with_salt *token
  end

  def token
    cookies.signed[:token] || [nil, nil]
  end

  def signin_auth
    signin_deny unless signed_in?
    @user = current_user
  end

  def signin_deny
    store_location
    redirect_to signin_path, :notice => "请先登陆再进行后续操作"
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_return_to
    session[:return_to] = nil
  end

  CHIEF_ADMINS = [
    'sjerrys@gmail.com',
    'mrsun3000@gmail.com',
    'blah@meh.org',
    'ai_no_kakera_a@hotmail.com',
    'lilu.life@gmail.com',
    'siyang1982@msn.com',
  ]
  def chief_admin_auth
    if not current_user && CHIEF_ADMINS.include?(current_user.email)
      render :nothing => true, :status => 418
    end
  end

  CONTENT_ADMINS = [
    'sjerrys@gmail.com',
    'pinkskyanger@yahoo.com.cn',
  ]
  def content_admin_auth
    if not current_user && CONTENT_ADMINS.include?(current_user.email)
      render :nothing => true, :status => 418
    end
  end

end
