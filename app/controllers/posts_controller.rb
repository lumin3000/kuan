# encoding: utf-8

class PostsController < ApplicationController
  before_filter :signin_auth, :except => [:wall, :news]
  before_filter :content_admin_auth, :only => [:all]


  def new
    @post = Post.new params
    get_target_blogs
  end

  def create
    params[:author] = current_user
    @post = Post.new params
    if @post.save
      respond_to do |format|
        format.json { render :text => {:status => "success"}.to_json }
        format.all { redirect_to home_path(@post.blog) }
      end
    else
      respond_to do |format|
        format.json { render :text => {
            :status => "error", 
            :message => @post.errors.values.first.first
          }.to_json }
        format.all { 
          get_target_blogs
          render 'new'
        }
      end
    end
  end

  def edit
    @post = Post.find(params[:id])
    if not @post.editable_by? @user
      render :status => :forbidden, :text => "放开那帖子"
    end
  end

  def update
    @post = Post.find(params.delete :id)
    if @post.update_attributes(params)
      redirect_to root_path
    else
      return render 'edit'
    end
  end

  def renew
    @parent = Post.find params[:id]
    @post = @parent.dup
    get_target_blogs
  end

  def recreate
    params[:parent] = Post.find params.delete(:parent_id)
    params[:author] = current_user
    @post = Post.new params
    if @post.save
      redirect_to home_path(@post.blog)
    else
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

  def favors
    params[:page] ||= 1
    limit = 10
    skip = (params[:page].to_i-1)*10
    @posts = current_user.favor_posts.reverse.slice skip, limit
    @posts ||= [] 
    @posts_count = current_user.favor_posts.count
    render :layout => 'main'
  end

  def news
    pagination = {
      :page => params[:page] || 1,
      :per_page => 10,
    }
    if params[:all]
      @posts = Post.publics.paginate(pagination)
    else
      @posts = Post.news(pagination)
    end
    render :layout => "common"
  end

  def all
    pagination = {
      :page => params[:page] || 1,
      :per_page => 50,
    }
    @posts = Post.all.paginate(pagination)
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
    @target_blogs = current_user.blogs
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
