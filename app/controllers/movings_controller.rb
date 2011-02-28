# -*- coding: utf-8 -*-
class MovingsController < ApplicationController
  layout 'minimal'

  before_filter :signin_auth
  
  def new
    @moving = Moving.new
  end

  def create
    @moving = Moving.new params[:moving]
    @moving.to_uri ||= @moving.from_uri
    @moving.user = current_user
    flash.now[:success] = "导入任务已成功记录，请等待导入完成" if @moving.save
    render 'new'
  end 

end
