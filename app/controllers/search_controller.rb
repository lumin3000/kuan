class SearchController < ApplicationController
  def index
    @keyword = params[:keyword]
    page = pagination_default[:page].to_i
    per_page = pagination_default[:per_page].to_i
    #search title and tags 
    @posts = Post.search("@(title,tags) #{@keyword}",
                         with: {private: [false]},
                         page: page,
                         per_page: per_page)
    
    
    if page > @posts.total_pages
      #search content
      @posts += Post.search("@content #{@keyword}",
                            with: {private: [false]},
                            page: page - @posts.total_pages,
                            per_page: per_page)
      @posts = @posts[0..per_page-1]
    end

    @posts = @posts.map {|p| p}
    
    render :layout => "common"
  end
end
