# -*- coding: utf-8 -*-
class MessagesController < ApplicationController
  before_filter :signin_auth
  before_filter :find_message, :only => [:ignore, :done]
  
  def index
    limit = 10
    params[:page] ||= 1
    skip = (params[:page].to_i-1)*10
    @messages = current_user.messages.reverse.slice skip, limit
    @messages ||= [] 
    @unread_count = current_user.messages.unreads.count
    current_user.read_all_messages! 
  end

  def ignore
    @message.ignore! unless @message.nil?
    respond_to do |format|
      format.json { render :json => {status: "success", message: "已忽略"}}
    end
  end

  def doing
    @message.doing! unless @message.nil?
    respond_to do |format|
      format.json { render :json => {status: "success", message: "已通过"}}
    end
  end

  private

  def find_message
    @message = current_user.messages.find params[:id]
  end

end
