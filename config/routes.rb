Rails.application.routes.draw do
  # Project routes
  resources :projects do
    # Subproject routes
    resources :subprojects do
      resources :journals, only: %i[new create show]
    end
  end

  # Region routes
  resources :regions, except: [:show]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "home#index"

  # User routes
  resources :users, except: %i[show]

  # Session routes
  get "/login", to: "sessions#login"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
