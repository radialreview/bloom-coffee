Rails.application.routes.draw do
  devise_for :users,
    path: "admin",
    skip: [ :registrations, :passwords ],
    path_names: { sign_in: "login", sign_out: "logout" }

  root "home#index"

  resources :menu, only: %i[index show], controller: "menu"

  resource :cart, only: %i[show], controller: "cart" do
    resources :items, only: %i[create update destroy], controller: "cart/items"
  end

  resources :orders, only: %i[create show]

  namespace :admin do
    root to: "dashboard#show"
    resources :drinks
    resources :add_ons
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in config/routes.rb too!)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
