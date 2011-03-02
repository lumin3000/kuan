class CommentsController < ApplicationController
  before_filter :signin_auth
  layout proc{ |c| c.request.xhr? ? false : "application" }   

  def index
    @post = Post.find(params[:post_id])
    puts params[:post_id]
    puts @post.comments
  end

  def create
    @post = Post.find(params[:post_id])
    redirect_to home_path if @post.nil?
    @comment = @post.comments.create({ :content => params[:content], :author_id => current_user.id})
    if @comment.save
      render "comments/index"
    else
      render "comments/index"
    end
  end

end
