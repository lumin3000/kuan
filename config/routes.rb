Kuan::Application.routes.draw do

  resources :sessions, :only => [:new, :create, :destroy]
  get '/signin', :to => 'sessions#new'
  get '/signout', :to => 'sessions#destroy'

  resources :users, :except => [:index, :destroy]
  get '/home(/:uri)(/page/:page)', :to => 'users#show', :page => /\d+/, :as => 'home'
  get '/signup/:code', :to => 'users#new', :as => :signup
  require 'constraints/subdomain'

  resources :blogs, :only => [:new, :create] do
    member do
      post :follow_toggle
    end
  end

  constraints(Subdomain) do
    get '/' => 'blogs#show'
    get '/kmon' => redirect('/')
    get '/(page/:page)' => 'blogs#show', :page => /\d+/
    get '/edit' => 'blogs#edit'
    put '/' => 'blogs#update'
    get '/posts/:post_id' => 'blogs#show'
    #Generating editor and follower resource would make more sense
    post '/follow_toggle' => 'blogs#follow_toggle'
    post '/rss_add' => 'blogs#rss_add'
    delete '/rss_remove/:feed_id' => 'blogs#rss_remove'
    get '/followers' => 'blogs#followers'
    match '/preview' => 'blogs#preview', :via => [:get, :post]
    match '/extract_template_vars' => 'blogs#extract_template_vars', :via => [:get, :post]
    get '/editors/new' => 'blogs#apply_entry'
    post '/editors' => 'blogs#apply'
    get '/editors' => 'blogs#editors'
    put '/editor/:user' => 'blogs#upgrade'
    delete '/editor/:user' => 'blogs#kick'
    delete '/exit' => 'blogs#exit'
    get '/customize' => redirect('/edit')
    get '/sync_apply/:target' => 'blogs#sync_apply'
    get '/sync_callback/:target' => 'blogs#sync_callback'
    delete '/sync/:target' => 'blogs#sync_cancel'
    get '/sync_widget/:target' => 'blogs#sync_widget'
    get '/feed' => 'blogs#feed', :format => :atom
  end

  post "/upload/:type", :to => 'images#create'
  post "/upload_log", :to => 'images#upload_log'
  get "/pics/:id(/:filename)", :to => redirect { |params| "/files/#{params[:id]}"}
  
  resources :posts, :except => [:new, :index, :show] do
    resources :comments
    member do
      get :renew
      put :favor_toggle
      put :mute_toggle
    end
    collection do
      post :recreate
    end
    get :reposts
    get :favor_list
  end

  post "/set_primary_blog/:uri" => "blogs#set_primary_blog", :as => "set_primary_blog"
  get "/posts/new/:type(/to/:blog_uri)" => "posts#new", :as => "new_post"
  post "/posts/fetch/:type(/to/:blog_uri)" => "posts#fetch", :as => "fetch_post"
  get '/favors(/page/:page)' => 'posts#favors', :page => /\d+/, :as => "favors_posts"
  get '/news(/page/:page)', :to => 'posts#news', :page => /\d+/, :as => "news_posts"
  get '/news/all(/page/:page)', :to => 'posts#news', :page => /\d+/, :all => true
  get '/wall', :to => 'posts#wall', :as => "wall_posts"
  get '/posts/all(/page/:page)', :to => 'posts#all', :page => /\d+/
  
  get '/followings', :to => 'users#followings'
  get '/buzz(/page/:page)', :to => 'users#buzz', :page => /\d+/, :as => "buzz"
  get '/buzz/unread(/page/:page)', :to => 'users#buzz', :page => /\d+/, :unread => true, :as => "buzz_unread"
  put '/buzz/readall', :to => 'users#read_all_comments_notices', :as => "buzz_readall"

  namespace :messages do
    get '(/page/:page)', :to => :index, :page => /\d+/
    put ':id/doing' => :doing, :as => "doing"
    put ':id/ignore' => :ignore, :as => "ignore"
  end

  get "/tag/:tag(/:scope)(/page/:page)" => "tags#show", page: /\d+/, as: 'tagged'
  get "/tags" => "tags#index"

  resources :movings, :only => [:new, :create]

  resources :templates do
    collection do
      post :submit
    end
  end

  match "/pop_the_gate/:action(/:blog_id)", :controller => :pop_the_gate

  get "/sitemap", :to => "sitemap#index", :as => "sitemap"

  get "/categories/manage", :to => "categories#manage", :as => "categories_manage"
  post "/categories/batch", :to => "categories#batch", :as => "categories_batch"
  get "/category/:name" => "categories#show", :as => 'category_by_name'
  resources :categories do
    resources :category_subs
  end

  match "/demos/:action", :controller => :demos
  
  root :to => redirect("/home")
end
