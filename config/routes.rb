Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", :as => :rails_health_check

  # FizzBuzz routes
  get "fizz_buzz", to: "fizz_buzz#index", as: "fizz_buzz"
  root "fizz_buzz#index"

  # User routes
  resources :users, only: [:new, :create, :show]

  # Session routes
  get "/login", to: "sessions#login"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
