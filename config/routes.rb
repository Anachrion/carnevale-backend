Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post "login", to: "sessions#create"
        delete "logout", to: "sessions#destroy"
        post "signup", to: "registrations#create"
        post "password", to: "passwords#create"
        patch "password", to: "passwords#update"
        patch "account", to: "registrations#update"
      end

      resources :lists
      resources :list_entries, only: %i[create update destroy]
      resources :profiles, only: %i[index show]
      resources :equipment, only: %i[index]
      resources :scenarios, only: %i[index]

      resources :games, only: %i[index create show destroy] do
        collection do
          post :join
        end
        member do
          patch :role
          get :available_lists
          patch :select_gang
          get "players/:player_id/list", action: :player_list
          post "agendas/draw", action: :draw_agendas
          post :ready
          patch :archive
          patch :unarchive
        end
      end
    end
  end

  mount ActionCable.server => "/cable"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # TODO: replace with the backoffice dashboard once it exists.
  root to: redirect("/users/sign_in")
end
