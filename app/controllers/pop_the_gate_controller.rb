class PopTheGateController < ApplicationController
  before_filter :find_blog, :except => [:blogs]
  before_filter :content_admin_auth

  def blogs
    @blogs = Blog.where :open_register => true
  end

  def turn_off
    @blog.open_register = false
    if @blog.save
      render text: 'done'
    else
      render text: 'fail', status: 500
    end
  end

  def turn_on
    @blog.open_register = true
    if @blog.save
      render text: 'done'
    else
      render text: 'fail', status: 500
    end
  end

  private
  def find_blog
    if not params[:blog_id].blank?
      @blog = Blog.find params[:blog_id]
    elsif not params[:blog_uri].blank?
      @blog = Blog.find_by_uri! params[:blog_uri]
    end
  end
end
