# -*- coding: utf-8 -*-
module SessionsHelper

  def sign_in(user)
    cookies.permanent.signed[:token] = [user.id, user.salt]
    current_user = user
  end

  def sign_out
    cookies.delete(:token)
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
end