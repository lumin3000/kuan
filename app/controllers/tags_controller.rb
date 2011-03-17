# -*- coding: utf-8 -*-
class TagsController < ApplicationController
  before_filter :signin_auth
  
  def show
    pagination = {
      :page => params[:page] || 1,
      :per_page => 10,
    }
    @tag = tag_unescape params[:tag]
    @posts = Post.tagged(@tag).paginate pagination
    @blogs = Blog.tagged(@tag).limit 10
    render :layout => "common"
  end

  def index
    @tags = Tag.hottest
    @tag_posts = Tag.hot_tag_posts
  end
end
