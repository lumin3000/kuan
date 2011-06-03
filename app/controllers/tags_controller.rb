# -*- coding: utf-8 -*-
class TagsController < ApplicationController

  def show
    @tag = tag_unescape params[:tag]
    @scope = params[:scope] || "all"
    post_filter = Post.all
    unless current_user.nil?
      post_filter = case @scope
                    when "bysubs"
                      Post.subs(current_user)
                    when "byme"
                      Post.author(current_user)
                    else
                      post_filter
                    end
    end
    @posts = post_filter.tagged(@tag).paginate(pagination_default)
    @blogs = Blog.tagged(@tag).limit(10)
    render layout: "common"
  end

  def index
    @tags = Tag.hottest
    @tag_posts = Tag.hot_tag_posts
    render layout: "common"
  end
end
