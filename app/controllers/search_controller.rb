# -*- coding: utf-8 -*-
class SearchController < ApplicationController
  def index
    @keyword = params[:keyword]
    page = pagination_default[:page].to_i
    per_page = pagination_default[:per_page].to_i
    scope = params[:scope] || "all"
    @blog = params[:blog]
    @scope_words = "在全站的搜索结果" 

    options = {
      with: {private: [false]},
      page: page,
      per_page: per_page
    }
    if scope == "subs" and not current_user.nil?
      options[:with][:blog_num_id] = current_user.all_blogs.reduce [], do |num_ids, blog|
        num_ids << blog.num_id if blog.open_to?(current_user)
        num_ids
      end
      options[:with][:private] = [true, false]
      @scope_words = "在我参与和关注的页面中的搜索结果" 
    end

    if scope == "blog"
      blog = Blog.find_by_uri!(request.subdomain)
      if not blog.nil? and blog.open_to?(current_user)
        options[:with][:blog_num_id] = [blog.num_id]
        options[:with][:private] = [true, false]
        @scope_words = %(在"#{blog.title}"页面中的检索结果)
      end
    end

    #search title and tags 
    @posts = Post.search("@(title,tags) #{@keyword}", options)

    #total_pages will crash when get 0 result
    if @posts.count > 0 and page > @posts.total_pages
      options[:page] -= @posts.total_pages
      #search content
      @posts += Post.search("@content #{@keyword}", options)
      @posts = @posts[0..per_page-1]
    end

    @posts = @posts.map {|p| p}
    
    render :layout => "common"
  end
end
