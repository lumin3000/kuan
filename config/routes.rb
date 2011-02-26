Kuan::Application.routes.draw do
  post "/upload/:type", :to => 'images#create'

  resources :posts

  resources :users, :except => [:index, :destroy] 

  resources :sessions, :only => [:new, :create, :destroy]
  resources :blogs do
    member do
      get :followers
      post :follow_toggle
    end
  end

  resources :movings, :only => [:new, :create]

  match "/posts/new/:type" => "posts#new"

  match '/signup/:code', :to => 'users#new', :as => :signup

  # FIXME: How to make it DRY?
  match '/home', :to => 'users#show'
  match '/home/page/:page', :to => 'users#show', :page => /\d+/
  match '/home/:uri', :to => 'users#show'
  match '/home/:uri/page/:page', :to => 'users#show', :page => /\d+/

  match '/followings', :to => 'users#followings'

  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  require 'constraints/subdomain'
  constraints(Subdomain) do
    match '/' => 'blogs#show'
    match '/followers' => 'blogs#followers'
    match '/page/:page' => 'blogs#show'
    match '/post/:post_id' => 'blogs#show'
  end

  root :to => "users#show"

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
