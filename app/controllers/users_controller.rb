# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :signin_auth, only: [:show, :edit, :update, :followings, :buzz, :read_all_comments_notices]
  before_filter :signup_auth, only: [:new, :create]

  before_filter :set_mobile_format, only: [:show, :buzz]

  def new
    if signed_in?
      redirect_to home_path and return
    end
    @user = User.new
    # @rand = rand(2)+1
    @rand = 0
    invitation_refer
    render layout: "application"
  end

  def create
    @user = User.new params[:user]
    @rand = params[:rand]
    return (render 'new', layout: "application") if !@user.save

    #create primary blog 
    @user.create_primary_blog!
    #follow inviter's open blogs
    @inv_user.blogs.each {|b| @user.follow! b unless b.private?}

    #follow administrator's blog
    business_config["signup_follow_blogs"].each do |uri|
      blog = Blog.find_by_uri! uri
      @user.follow! blog unless blog.nil?
    end

    sign_in @user
    flash[:success] = "欢迎注册"
    #log register user's reference
    logging_refer
    redirect_to params[:redirect_back] ? params[:refer] : categories_path
  end

  def show
    @blog = @user.primary_blog
    @blogs = @user.blogs
    #param :uri: 显示指定uri的blog的信息和帖子列表，否则使用默认页面
    @at_dashboard = params[:uri].blank?
    if !@at_dashboard
      param_blog = Blog.where(uri: params[:uri]).first
      @blog = @user.blogs.include?(param_blog) ? param_blog : @blog
      posts_c = Post.where({blog_id: @blog.id})
    else
      @blog = nil
      posts_c = Post.subs(@user)
    end
    @posts = posts_c.desc(:created_at).page(params[:page])
    render layout: "common"
  end

  def buzz
    if(params[:unread])
      @buzz_list = Kaminari.paginate_array(current_user.unread_comments_notices_list).page(params[:page])
      @unread = true
    else
      @buzz_list = Kaminari.paginate_array(current_user.comments_notices_list).page(params[:page])
    end
    render layout: "main"
  end

  def read_all_comments_notices
    current_user.read_all_comments_notices!
    respond_to do |format|
      format.json { render :text => {status: "success", location: home_path}.to_json }
    end
  end

  def edit
    render layout: "account"
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
      render 'edit', layout: "account"
    end
  end

  def followings
    @blogs = @user.subs
    render layout: "main"
  end

  private

  def signup_auth
    render 'shared/404', status: 404 and return if params[:code].blank?
    @inv_user = User.find_by_code params[:code]
    render 'shared/404', status: 404 if @inv_user.nil? 
  end

  def logging_refer
    logger = Logger.new("#{Rails.root.to_s}/log/register_refer.log")
    logger.info %(#{Time.now} : #{request.remote_ip} : #{@user.email} : #{params[:refer]} : #{params[:rand]} : #{params[:code]})
  end

  def invitation_refer
    logger = Logger.new("#{Rails.root.to_s}/log/invitation_refer.log")
    logger.info %(#{Time.now} : #{request.remote_ip} : #{params[:code]} : #{request.referer})
  end
end
