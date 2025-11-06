Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "home#index"

  # FizzBuzz routes
  get "fizz_buzz", to: "fizz_buzz#index", as: "fizz_buzz"

  # User routes
  resources :users, only: %i[new create show]

  # Session routes
  get "/login", to: "sessions#login"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
