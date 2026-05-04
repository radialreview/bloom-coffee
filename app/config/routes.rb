Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :menu, only: %i[index show], controller: "menu"

  resource :cart, only: %i[show], controller: "cart" do
    resources :items, only: %i[create update destroy], controller: "cart/items"
  end

  resources :orders, only: %i[index create show]

  get "settings", to: "settings#show", as: :settings

  namespace :admin do
    get    "login",  to: "sessions#new",     as: :login
    post   "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout

    root "dashboard#show"

    resources :drinks,  except: %i[show]
    resources :add_ons, except: %i[show]
  end

  root "menu#index"
end
