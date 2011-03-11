# -*- coding: utf-8 -*-
class BlogsController < ApplicationController
  before_filter :signin_auth, :except => [:show]
  before_filter :custom_auth, :only => [:edit, :update, :upgrade, :kick]
  before_filter :editor_auth, :only => [:followers, :editors, :exit]
  before_filter :find_by_uri, :only => [:show, :follow_toggle, :apply, :apply_entry]

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
    p = params[:blog]
    p.delete :icon if p[:icon].blank?
    if @blog.update_attributes p
      flash[:success] = "页面信息更新成功"
      redirect_to blog_path(@blog)
    else
      render 'edit'
    end
  end

  def show
    if not @blog.open_to?(current_user)
      render 'shared/403', :status => 403, :layout => false and return
    end
    post_id = params[:post_id]
    @single_post = ! post_id.nil?
    if !@single_post
      @posts = Post.desc(:created_at).where({:blog_id => @blog.id})
        .paginate({
                    :page => params[:page] || 1,
                    :per_page => 10,
                  })

    else
      @posts = [Post.find(post_id)]
      @post = @posts.first
    end
    render :layout => false
  end

  def followers
    @followers = @blog.followers
  end

  def follow_toggle
    if @blog.followed? current_user
      current_user.unfollow! @blog
      now_follow = false
    elsif @blog.unfollowed? current_user
      current_user.follow! @blog
      now_follow = true
    end
    respond_to do |format|
      format.js { @follow = now_follow }
    end
  end

  def apply
    @blog.applied(current_user, params[:content])
    render "apply_processed", :layout => "apply"
  end

  def apply_entry
    unless @blog.applied?(current_user)
      @message = "现在不能申请哦"
      render 'shared/403', :status => 403, :layout => false and return
    end

    render "apply", :layout => "apply"
  end

  def editors
    @editors = @blog.founders + @blog.members
  end
  
  def upgrade
    user = User.find params[:user]
    user.follow! @blog, "founder"
    respond_to do |format|
      format.json { render :json => {status: "success", message: "管理员" } }
    end
  end

  def kick
    user = User.find params[:user]
    user.unfollow! @blog unless @blog.customed? user
    respond_to do |format|
      format.json { render :json => {status: "success" } }
    end
  end

  def exit
    current_user.unfollow! @blog if @blog.canexit? current_user 
    respond_to do |format|
      format.json { render :json => {status: "success", location: fucking_root } }
    end
  end

  private

  def custom_auth
    find_by_uri
    redirect_to home_path unless @blog.customed? current_user
  end

  def editor_auth
    find_by_uri
    redirect_to home_path unless @blog.edited? current_user
  end

  def find_by_uri(uri = nil)
    @blog = Blog.find_by_uri!(uri || params[:uri] || params[:id] || request.subdomain)
    render 'shared/404', :status => 404, :layout => false if @blog.nil?
  end
end
