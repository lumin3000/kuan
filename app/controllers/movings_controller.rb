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
    flash.now[:success] = %(搬家任务已成功记录，预计最长需要1天左右完成：
                            http://#{@moving.to_uri}.#{request.domain}) if @moving.save
    render 'new'
  end

end
