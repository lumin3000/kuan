# -*- coding: utf-8 -*-
class MovingsController < ApplicationController
  layout 'minimal'

  #before_filter :signin_auth
  #2011-4-14 stop moving
  before_filter :forbid_moving

  def new
    @moving = Moving.new
  end

  def create
    @moving = Moving.new params[:moving]
    @moving.to_uri ||= @moving.from_uri
    @moving.user = current_user
    flash.now[:success] = %(搬家任务已成功记录，预计最长需要1天左右完成：
                            http://#{@moving.to_uri}.#{request.domain}) if @moving.save
    render 'new'
  end

  private

  def forbid_moving
    render :text => "搬家功能已废弃", :status => 404, :content_type => 'text/plain'
  end
end
