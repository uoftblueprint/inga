Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # FizzBuzz routes
  get  "fizz_buzz", to: "fizz_buzz#index", as: "fizz_buzz"
  root "fizz_buzz#index"
end
