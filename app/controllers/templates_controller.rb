# encoding: utf-8
require 'cgi'

class TemplatesController < ApplicationController
  before_filter :chief_admin_auth, :except => [:show, :submit]
  before_filter :strip_emtpy_thumb_id, :only => [:create, :update]

  def submit
    @template = Template.new params
    @template.author = current_user
    @template.public = false
    if @template.save
      render :status => 204
    else
      render :status => 400
    end
  end

  def index
    @templates = Template.all
  end

  def edit
    @template = Template.find params[:id]
  end

  def show
    @template = if params[:id] == 'default'
                  Template::DEFAULT
                else
                  Template.find params[:id]
                end
    render :text => CGI.escapeHTML(@template.html, :content_type => 'text/plain'
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

  def strip_emtpy_thumb_id
    p = params[:template]
    return unless p.is_a? Hash
    p.delete :thumbnail if p[:thumbnail].blank?
  end
end
