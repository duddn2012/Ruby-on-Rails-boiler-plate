Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    # Users
    resources :users, only: [:create, :show, :update, :destroy] do
      collection do
        get :profile
        patch :update_profile
      end
    end
    
    # Products
    resources :products, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :search
        get :categories
        get :brands
        get 'by_ingredient/:ingredient_id', to: 'products#by_ingredient'
      end
    end
    
    # Ingredients
    resources :ingredients, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :search
        get :effects
        get :safety_levels
        get :popular
        get 'by_effect/:effect', to: 'ingredients#by_effect'
        get 'by_safety/:safety_level', to: 'ingredients#by_safety'
      end
    end
    
    # Recommendations
    resources :recommendations, only: [:index, :show, :create, :update, :destroy] do
      collection do
        post :generate
        post :by_ingredient
        get :stats
        get 'user/:user_id', to: 'recommendations#user_recommendations'
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
