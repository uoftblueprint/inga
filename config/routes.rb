Rails.application.routes.draw do
  # Project routes
  resources :projects do
    resource :attributes_schema, controller: "project_attributes", only: %i[update edit] do
      get :new_row
    end
    # Subproject routes
    resources :subprojects
  end

  # Region routes
  resources :regions, except: [:show]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "home#index"

  # User routes
  resources :users

  # Session routes
  get "/login", to: "sessions#login"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
