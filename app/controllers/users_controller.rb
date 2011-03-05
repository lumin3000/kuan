# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :signin_auth, :only => [:show, :edit, :update, :followings, :buzz, :read_all_comments_notices]
  before_filter :signup_auth, :only => [:new, :create]

  SIGNUP_FOLLOW_BLOGS = %w[kuaniao]

  def new
    if signed_in?
      redirect_to '/home' and return
    end
    @user = User.new
    render :layout => "user"
  end

  def create
    @user = User.new params[:user]
    return (render 'new', :layout => "user") if !@user.save

    #create primary blog 
    @user.create_primary_blog!
    #follow inviter's open blogs
    @inv_user.blogs.each {|b| @user.follow! b unless b.private?}

    #follow administrator's blog
    SIGNUP_FOLLOW_BLOGS.each do |uri|
      blog = Blog.find_by_uri! uri
      @user.follow! blog unless blog.nil?
    end

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
      :per_page => 10,
    }
    @at_dashboard = params[:uri].blank?
    if !@at_dashboard
      param_blog = Blog.where(:uri => params[:uri]).first
      @blog = @user.blogs.include?(param_blog) ? param_blog : @blog
      cond = {:blog_id => @blog.id}
    else
      sub_id_list = @user.all_blogs.reduce [], do |list, blog|
        if blog.open_to?(@user) then list << blog.id else list end
      end
      cond = {:blog_id.in => sub_id_list}
    end
    @posts = Post.desc(:created_at).where(cond).paginate(pagination)
    @count_unread_comments_notices = current_user.count_unread_comments_notices
  end

  def buzz
    pagination = {
      :page => params[:page] || 1,
      :per_page => 10,
    }
    @buzz_list = current_user.comments_notices_list(pagination)
    @unread_count = current_user.count_unread_comments_notices
  end

  def read_all_comments_notices
    current_user.read_all_comments_notices!
    respond_to do |format|
      format.json { render :text => {status: "success", location: home_path}.to_json }
    end
  end

  def edit
    render :layout => "account"
  end

  def update
    if(params[:user][:password].blank? && params[:user][:password_confirmation].blank?)
       params[:user].delete(:password)
       params[:user].delete(:password_confirmation)
    end

    if @user.update_attributes params[:user]
      flash[:success] = "帐户信息更新成功"
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
