class SitemapController < ApplicationController
  def index
    @blogs = Blog.latest[0..30].sample(5)
    render :layout => "common"
  end
end
