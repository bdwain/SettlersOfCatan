SettlersOfCatan::Application.routes.draw do
  root :to => 'home#index'
  get "home/index"


  resources :games, only: [:index, :show, :new, :create], shallow: true do
      resources :players, only: [:create, :destroy], shallow: true do
        resource :dice_rolls, only: [:create]
        #resources :game_logs
        resource :roads, only: [:create]
        resource :settlements, only: [:create]
        resource :resources, only: [:update], via: [:patch]
        match "robber_victim" => "players#choose_robber_victim", via: [:post]
      end

      match "robber" => "games#move_robber", via: [:put]
      #resources :chats
      #resources :development_cards
  end
  
  #resources :maps, :shallow: true do
    #resources :harbors
    #resources :hexes
  #end

  devise_for :users

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
  

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
