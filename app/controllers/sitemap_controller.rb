class SitemapController < ApplicationController
  def index
    @blogs = Blog.latest.limit(30).sample(5)
    render :layout => "common"
  end
end
