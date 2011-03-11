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
    get '/(page/:page)' => 'blogs#show', :page => /\d+/
    get '/edit' => 'blogs#edit'
    put '/' => 'blogs#update'
    get '/posts/:post_id' => 'blogs#show'
    #Generating editor and follower resource would make more sense
    post '/follow_toggle' => 'blogs#follow_toggle'
    get '/followers' => 'blogs#followers'
    get '/editors/new' => 'blogs#apply_entry'
    post '/editors' => 'blogs#apply'
    get '/editors' => 'blogs#editors'
    put '/editor/:user' => 'blogs#upgrade'
    delete '/editor/:user' => 'blogs#kick'
    delete '/exit' => 'blogs#exit'
  end

  post "/upload/:type", :to => 'images#create'
  
  resources :posts, :except => [:new, :index, :show] do
    resources :comments
    member do
      get :renew
      put :favor_toggle
    end
    collection do
      post :recreate
    end
  end

  get "/posts/new/:type(/to/:blog_uri)" => "posts#new", :as => "new_post"
  get '/news(/page/:page)', :to => 'posts#news', :page => /\d+/
  get '/wall', :to => 'posts#wall'
  get '/posts/favors(/page/:page)' => 'posts#favors', :page => /\d+/
  
  get '/followings', :to => 'users#followings'
  get '/buzz(/page/:page)', :to => 'users#buzz', :page => /\d+/
  put '/buzz/readall', :to => 'users#read_all_comments_notices'

  get '/messages(/page/:page)', :to => 'messages#index', :page => /\d+/
  put '/messages/:id/doing', :to => 'messages#doing'
  put '/messages/:id/ignore', :to => 'messages#ignore'

  resources :movings, :only => [:new, :create]

  root :to => redirect("/home")
  

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
