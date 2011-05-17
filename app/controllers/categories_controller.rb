# -*- coding: utf-8 -*-
class CategoriesController < ApplicationController
  before_filter :content_admin_auth, :except => [:index, :show]
  layout "common"

  def index
    @categories = Category.all
    @top_categories = Category.top_categories

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  def show
    @category = Category.find_by_name!(params[:name])
    render 'shared/404', :status => 404, :layout => false and return if @category.nil?

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end

  def manage
    @categories = Category.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  def new
    @category = Category.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        format.html { redirect_to(categories_manage_path, :notice => '创建成功') }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(categories_manage_path, :notice => '修改成功') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_manage_path) }
      format.xml  { head :ok }
    end
  end

  def batch
    content = params[:content]
    arr = content.split("\r\n")
    @current_c = nil
    arr.each do |str|
      str.strip!
      unless str.blank?
        if str.start_with?('http')
          uri = str.split(/\/|\./)[2]
          @blog = Blog.find_by_uri!(uri)
          unless @blog.blank?
            @category_sub = @current_c.category_subs.create(blog_id: @blog.id)
            @category_sub.save
          end
        else
          @current_c = Category.new(name: str)
          @current_c.save
        end
      end
    end
    redirect_to(categories_manage_path, :notice => '批量创建成功')
  end
end
