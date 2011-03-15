# encoding: utf-8

class TemplatesController < ApplicationController
  def index
    @templates = Template.all
  end

  def edit
    @template = Template.find params[:id]
  end

  def show
    @template = Template.find params[:id]
    render :text => @template.html, :content_type => 'text/html'
  end

  def new
    @template = Template.new
    render :edit
  end

  def create
    author = User.where(params.delete :author).first
    @template = Template.new params[:template]
    @template.author = author
    if @template.save
      flash.now[:info] = 'Done!'
      redirect_to :action => :index
    else
      render :edit
    end
  end

  def update
    @template = Template.find(params.delete :id)
    author = User.where(params.delete :author).first
    @template.author = author
    if @template.update_attributes params[:template]
      flash.now[:info] = 'Done!'
      render :edit
    else
      render :edit
    end
  end

  def destroy
    @template = Template.find(params[:id])
    if @template.nil?
      render :nothing => true, :status => 404 and return
    end
    @template.destroy
    render :text => '{}', :status => 200
  end
end
