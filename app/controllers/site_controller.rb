class SiteController < ApplicationController
  def public_timeline
    @posts = Post.limit(10).desc(:created_at)
  end

end
