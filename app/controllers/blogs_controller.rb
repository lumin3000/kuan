# -*- coding: utf-8 -*-
class BlogsController < ApplicationController
  before_filter :signin_auth, :except => [:show]
  before_filter :custom_auth, :only => [:edit, :update, :upgrade, :kick, :customize]
  before_filter :editor_auth, :only => [:followers, :editors, :exit]
  before_filter :find_by_uri, :only => [:show, :follow_toggle, :apply, :apply_entry,
    :extract_template_vars, :customize]
  before_filter :blog_display, :only => [:show, :preview]

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

  def customize
    @templates = Template.all.to_a
    @templates.unshift(Template::DEFAULT)
    @variables = BlogView.extract_variables(@blog)
    render :layout => 'application'
  end

  def update
    p = params[:blog]
    p.delete :icon if p[:icon].blank?
    p[:template_id] = nil if p[:template_id].blank?
    if @blog.update_attributes p
      flash[:success] = "页面信息更新成功"
      redirect_to blog_path(@blog)
    else
      render 'edit'
    end
  end

  def preview
    build_view_context
    fetch_posts
    p = params[:blog]
    p.delete :template_id if p[:template_id].blank?
    @blog.use_template params[:blog]
    render_blog
  end

  def extract_template_vars
    p = params[:blog]
    p.delete :template_id if p[:template_id].blank?
    @blog.use_template p
    @variables = BlogView.extract_variables @blog
    render 'blogs/_template_variables', :layout => false
  end

  def show
    build_view_context
    fetch_posts
    render_blog
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

  def blog_display
    find_by_uri
    render 'shared/404', :status => 404, :layout => false and return if @blog.nil?
    if not @blog.open_to?(current_user)
      render 'shared/403', :status => 403, :layout => false and return
    end
  end

  def build_view_context
    url_template = "http://%%s.%s%s/" % [request.domain, request.port_string]
    @view_context = {
      :url_template => url_template,
      :base_url => url_template % @blog.uri,
      :home_url => url_template % 'www',
      :controller => self,
      :current_user => current_user
    }
    @post_id = params[:post_id]
    @single_post = ! @post_id.nil?
    @view_context[:post_single] = @single_post
  end

  def fetch_posts
    if !@single_post
      cur_page = params[:page].to_i
      per_page = 10
      pagination = {
        :page => cur_page > 1 ? cur_page : 1,
        :per_page => per_page,
        :total_pages => @blog.total_post_num.fdiv(per_page).ceil,
      }
      @view_context[:pagination] = pagination
      @posts = Post.desc(:created_at).where({:blog_id => @blog.id})
        .paginate(pagination)

    else
      @posts = [Post.find(@post_id)]
      @post = @posts.first
    end
    @view_context.update :posts => @posts
  end

  def render_blog()
    begin
      view = BlogView.new @blog, @view_context
      rendered = view.render
      control_buttons = view.control_buttons
      rendered['</body>'] = "#{control_buttons}</body>"
      render :text => rendered
    rescue Mustache::Parser::SyntaxError => e
      render :status => 400, :text => "模板语法错误：\n#{e.to_s}",
        :content_type => 'text/plain'
    end
  end
end
