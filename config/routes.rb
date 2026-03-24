Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Locale scope
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    # Project routes
    resources :projects do
      resource :attributes_schema, controller: "project_attributes", only: %i[update edit] do
        get :new_row
      end
      # Subproject routes
      resources :subprojects, except: [:index] do
        resources :journals, except: [:index], controller: "projects/subprojects/journals"
        resources :log_entries, except: [:index], controller: "projects/subprojects/log_entries"
      end
    end

    # Region routes
    resources :regions, except: [:show]

    # Generic Log Entry routes
    resources :log_entries, only: %i[new]

    # Generic Journal Entry routes
    resources :journals, only: %i[new] do
      member do
        get :form_card
      end
    end

    root to: "projects#index"

    # User routes
    resources :users

    # Session routes
    get "/login", to: "sessions#login"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    # Report routes
    resources :reports, only: %i[index show new create edit update destroy] do
      collection do
        get :filter
      end
    end
  end
end
