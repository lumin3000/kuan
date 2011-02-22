# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :signin_auth, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    return render 'new' if !@user.save

    #create primary blog
    blog = Blog.new(:title => @user.name,
                    :uri => nametouri(@user.name))
    blog.primary = true
    blog.save
    @user.follow Following.new(:blog => blog, :auth => "lord")

    sign_in @user
    flash[:success] = "欢迎注册"
    redirect_to home_path
  end

  def show
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

  private

  #1,将中文名字转成域名允许的格式，并填充到4
  #2,读取数据库中已有uri,如重名则在后面加数字
  #3,如同名uri已有多个，则取后面数字最大的并+1拼出新的uri
  def nametouri(name)
    require 'pinyin'
    uri = PinYin.instance.to_pinyin(name).downcase.ljust(4,'k')
    return uri if Blog.where(:uri => uri).empty?
    uri + (Blog.where(:uri => /^#{uri}/).reduce(0) do |max, b|
             n = b.uri.match(/^#{uri}([0-9]*)$/)[1].to_i
             (n > max) ? n : max
           end.to_i+1).to_s
  end

end
