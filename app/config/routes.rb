Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#index"

  namespace :admin do
    get    "login",  to: "sessions#new",     as: :login
    post   "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout

    root "dashboard#show"

    resources :drinks, except: %i[show]
  end
end
