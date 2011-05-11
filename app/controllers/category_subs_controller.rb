# -*- coding: utf-8 -*-
class CategorySubsController < ApplicationController
  before_filter :content_admin_auth, :except => []

  def new
    @category = Category.find(params[:category_id])
    @category_sub = @category.category_subs.build
    respond_to do |format|
      format.html
    end
  end

  def edit
    @category = Category.find(params[:category_id])
    @category_sub = @category.category_subs.find(params[:id])
  end

  def create
    @category = Category.find(params[:category_id])
    @blog = Blog.find_by_uri!(params[:uri])
    if @blog.nil?
      redirect_to new_category_category_sub_path(@category)
      return
    end
    params[:category_sub][:blog_id] = @blog.id

    @category_sub = @category.category_subs.create(params[:category_sub])

    respond_to do |format|
      if @category_sub.save
        format.html { redirect_to(categories_manage_path, :notice => '创建成功') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @category = Category.find(params[:category_id])
    @category_sub = @category.category_subs.find(params[:id])

    respond_to do |format|
      if @category_sub.update_attributes(params[:category_sub])
        format.html { redirect_to(categories_manage_path, :notice => '修改成功') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @category = Category.find(params[:category_id])
    @category_sub = @category.category_subs.find(params[:id])
    @category_sub.destroy

    respond_to do |format|
      format.html { redirect_to(categories_manage_path) }
      format.xml  { head :ok }
    end
  end
end
