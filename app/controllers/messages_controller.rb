class MessagesController < ApplicationController
  before_filter :signin_auth

  def index
    limit = 10
    params[:page] ||= 1
    skip = (params[:page].to_i-1)*10
    @messages = current_user.messages.reverse.slice skip, limit
    @messages ||= [] 
    @unread_count = current_user.messages.unreads.count
    current_user.read_all_messages! 
  end

end
