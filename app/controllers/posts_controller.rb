# encoding: utf-8

class PostsController < ApplicationController
  before_filter :signin_auth, :except => [:wall, :news]
  before_filter :content_admin_auth, :only => [:all]
  before_filter :set_mobile_format, only: [:new, :create, :news]

  def new
    @post = Post.new params
    @referer = request.referer
    get_target_blogs
  end

  def create
    params[:author] = current_user
    @post = Post.new params
    if @post.save
      respond_to do |format|
        format.json { render :text => {:status => "success"}.to_json }
        format.all { 
          session[:post_id] = @post.id
          redirect_to(home_path(@post.blog))
          #redirect_to(params[:referer].include?(home_path(@post.blog)) ? params[:referer] : home_path)
        }
      end
    else
      respond_to do |format|
        format.json { render :text => {
            :status => "error", 
            :message => @post.errors.values.first.first
          }.to_json }
        format.all { 
          @referer = params[:referer]
          get_target_blogs
          render 'new'
        }
      end
    end
  end

  def edit
    @post = Post.find(params[:id])
    @referer = request.env["HTTP_REFERER"]
    if not @post.editable_by? @user
      render :status => :forbidden, :text => "放开那帖子"
    end
  end

  def update
    @post = Post.find(params.delete :id)
    if @post.update_attributes(params)
      session[:post_id] = @post.id
      if params[:referer].blank?
        redirect_to posts_blog_path(@post)
      else
        redirect_to params[:referer]
      end
    else
      @referer = params[:referer]
      return render 'edit'
    end
  end

  def renew
    @parent = Post.find params[:id]
    @post = @parent.dup
    @referer = request.referer
    get_target_blogs
  end

  def recreate
    params[:parent] = Post.find params.delete(:parent_id)
    params[:author] = current_user
    @post = Post.new params
    if @post.save
      session[:post_id] = params[:parent].id
      redirect_to params[:referer] || home_path
    else
      @referer = params[:referer]
      get_target_blogs
      render 'renew'
    end
  end
  
  def fetch
    @post = Post.new params
    @p = params
    get_target_blogs
  end

  def destroy
    @post = Post.find(params[:id])
    if(@post.nil? || !(@post.editable_by? @user))
      respond_to do |format|
        format.json {render :status => 403, :nothing => true}
      end
      return
    end
    blog = @post.blog
    @post.destroy
    respond_to do |format|
      format.json { render :text => {:status => "success", :location => root_url}.to_json }
    end
  end

  def favor_toggle
    @post = Post.find params[:id]
    if @post.favored_by? current_user
      current_user.del_favor_post! @post
    else
      current_user.add_favor_post! @post
    end

    respond_to do |format|
      format.json { render :text => {:status => "success"}.to_json }
    end
  end

  def mute_toggle
    post = Post.find params[:id]
    if post.muted_by?(current_user)
      current_user.unmute! post
    else
      current_user.mute! post
    end
    
    respond_to do |format|
      format.json { render :text => {:status => "success"}.to_json }
    end
  end

  def favors
    params[:page] ||= 1
    limit = 10
    skip = (params[:page].to_i-1)*10
    @posts = current_user.favor_posts.reverse.slice skip, limit
    @posts ||= [] 
    @posts_count = current_user.favor_posts.count
    render :layout => 'main'
  end

  def reposts
    @post = Post.find(params[:post_id])
    render partial: "posts/reposts", layout: false
  end

  def favor_list
    @post = Post.find(params[:post_id])
    @favors = @post.favors
    render partial: "posts/favors", layout: false
  end

  def news
    @posts = params[:all] ? Post.publics(params[:page]) : Post.news(params[:page])
    @news_channel = Post.news_channel
    render :layout => "common"
  end

  def all
    @posts = Post.all_by_updated.page(params[:page]).per(50)
    render "news", :layout => "common"
  end

  def wall
    @posts = Post.wall
    if params[:format] && params[:format] == "html"
      render partial: "posts/brief", collection: @posts, as: :post
    else
      render :layout => "application"
    end
  end

  private

  def get_target_blogs
    webmaster = User.where(:email => "kuankuandao@gmail.com").first

    #@target_blogs = current_user.blogs.concat(webmaster.blogs)
    temp_blogs = current_user.blogs
    webmaster.blogs.each do |blog|
      temp_blogs.push(blog) unless temp_blogs.include?(blog)
    end
    @target_blogs = temp_blogs
    get_default_target
  end

  def get_default_target
    @default_target_blog = @post.blog || if params[:blog_uri].blank?
                               current_user.primary_blog
                             else
                               Blog.find_by_uri!(params[:blog_uri])
                             end
  end
end
