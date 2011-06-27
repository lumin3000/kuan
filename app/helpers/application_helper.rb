# -*- coding: utf-8 -*-
require 'uri'

module ApplicationHelper
  def js(space)
    @js ||= []
    @js.delete space
    @js.unshift space 
  end

  def css(space)
    @css ||= []
    @css.delete space
    @css.unshift space 
  end

  def use_header(t=nil)
    if(t.nil?)
      render partial: "layouts/header"
    else
      render partial: "layouts/header_#{t}"
    end
  end

  def pagination(collection, options = {})
    options = { :per_page => 10, :collection => collection }.update(options)
    paging_info = compose_pagination(request.url, options)
    render :partial => 'shared/pagination', :locals => paging_info
  end

  def compose_pagination(url, opt)
    current_page, base_url = infer_pagination(url)
    result = {current_page: current_page, base_url: base_url}
    collection = opt[:collection]
    if current_page > 1
      result[:prev_page_url] = base_url.dup.tap{|u| u.path += "/page/#{current_page - 1}"}
    end
    if !collection.blank? && collection.length >= opt[:per_page]
      result[:next_page_url] = base_url.dup.tap{|u| u.path += "/page/#{current_page + 1}"}
    end
    result.update(opt)
  end

  def infer_pagination(url_str)
    url = URI.parse url_str
    if m = %r{/page/(\d+)/?$}.match(url.path)
      url.path[m.to_s] = ''
      [m[1].to_i(10), url]
    else
      [1, url.tap{|u| u.path.sub! /\/$/, ''}]
    end
  end

  def pagination_standard(options = {})
    options = { max_page: 10, show_page: 10, default_position: 4 }.update(options)

    current_page, base_url = infer_pagination(request.url)

    if current_page < options[:default_position]
      start_page = 1
    elsif current_page > options[:max_page] - options[:show_page] + options[:default_position] - 1
      start_page = options[:max_page] - options[:show_page] + 1
    else
      start_page = current_page - options[:default_position] + 1
    end
    end_page = start_page + options[:show_page] - 1

    pages = []
    start_page.upto(end_page) do |i|
      pages << {
        url: base_url.dup.tap{|u| u.path += "/page/#{i}"},
        current?: current_page == i,
        num: i
      }
    end

    render partial: "shared/pagination_standard", locals: {
      pages: pages,                                                                               
      start_page: start_page,
      end_page: end_page,
    }
  end

  def blog_list
    if params[:controller] == 'users' && params[:action] == 'show'
      path = :home_path
    elsif params[:controller] == 'blogs' && params[:action] == 'followers'
      path = :followers_blog_path
    elsif params[:controller] == 'blogs' && params[:action] == 'editors'
      path = :editors_blog_path
    end
    render partial: 'layouts/blogs', locals: {
      path: method(path)
    }
  end

  def content_summary(post, length=400, summary_length=60)
    c = strip_tags(post.content)
    if(!c.blank? && c.length>length)
      suffix = " <a href=\""+posts_blog_path(post)+"\" target=\"_blank\">查看全文</a>"
      truncate(c, length: summary_length) + suffix
    else
      post.content
    end
  end
  
  def search_bar(scope=nil)
    render partial: 'shared/search', locals: {scope: scope}
  end
end
