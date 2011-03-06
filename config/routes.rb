Kuan::Application.routes.draw do
  post "/upload/:type", :to => 'images#create'

  resources :posts do
    resources :comments
  end

  resources :users, :except => [:index, :destroy] 

  resources :sessions, :only => [:new, :create, :destroy]
  resources :blogs, :only => [:new, :create], do
    member do
      post :follow_toggle
    end
  end

  resources :movings, :only => [:new, :create]

  get "/posts/new/:type" => "posts#new"
  get "/posts/new/:type/to/:blog_uri" => "posts#new"

  get '/signup/:code', :to => 'users#new', :as => :signup

  # FIXME: How to make it DRY?
  get '/home', :to => 'users#show'
  get '/home/page/:page', :to => 'users#show', :page => /\d+/
  get '/home/:uri', :to => 'users#show'
  get '/home/:uri/page/:page', :to => 'users#show', :page => /\d+/

  get '/followings', :to => 'users#followings'
  get '/buzz', :to => 'users#buzz'
  get '/buzz/page/:page', :to => 'users#buzz', :page => /\d+/
  put '/buzz/readall', :to => 'users#read_all_comments_notices'

  get '/messages', :to => 'messages#index'
  get '/messages/page/:page', :to => 'messages#index', :page => /\d+/
  post '/messages/:id/doing', :to => 'messages#doing'
  post '/messages/:id/ignore', :to => 'messages#ignore'

  get '/signin', :to => 'sessions#new'
  get '/signout', :to => 'sessions#destroy'

  require 'constraints/subdomain'
  constraints(Subdomain) do
    get '/' => 'blogs#show'
    put '/' => 'blogs#update'
    get '/followers' => 'blogs#followers'
    get '/editors' => 'blogs#editors'
    get '/edit' => 'blogs#edit'
    post '/blogs/:id/follow_toggle' => 'blogs#follow_toggle'
    post '/apply' => 'blogs#apply'
    get '/page/:page' => 'blogs#show', :page => /\d+/
    get '/post/:post_id' => 'blogs#show'
  end

  root :to => 'users#show'
  get '/page/:page', :to => 'users#show', :page => /\d+/

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
