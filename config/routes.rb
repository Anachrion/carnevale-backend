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

      # Short-lived, single-use credential for opening the ActionCable WebSocket (see CableTicket).
      post "cable_tickets", to: "cable_tickets#create"

      resources :lists, only: %i[index show create update destroy]
      resources :list_entries, only: %i[create update destroy] do
        member do
          patch :spells
        end
      end
      resources :profiles, only: %i[index show]
      get "cards/manifest", to: "cards#manifest"
      resources :abilities, only: %i[index]
      resources :equipment, only: %i[index]
      resources :scenarios, only: %i[index]
      resources :spells, only: %i[index]

      resources :games, only: %i[index create show destroy] do
        collection do
          post :join
        end
        member do
          patch :role
          get :available_lists
          patch :select_gang
          delete :select_gang, action: :deselect_gang
          get "players/:player_id/list", action: :player_list
          post "agendas/draw", action: :draw_agendas
          post "agendas/confirm", action: :confirm_agendas
          post "agendas/:agenda_id/score", action: :score_agenda
          post "agendas/:agenda_id/discard", action: :discard_agenda
          post "turns/advance", action: :advance_turn
          post "turns/rewind", action: :rewind_turn
          post :finish
          post :unfinish
          # Models conjured mid-game by a special rule. They join the player's (otherwise frozen)
          # gang, and only they can be removed again — the hired roster stays locked.
          post "summons", action: :summon
          delete "summons/:list_entry_id", action: :dismiss_summon
          patch "entries/:list_entry_id/counters", action: :update_counters
          patch "entries/:list_entry_id/stats", action: :update_stats
          patch :archive
          patch :unarchive
        end
      end
    end
  end

  # Card-authoring backoffice: browse profiles, render/export card faces, edit illustration
  # framing, and push freshly rendered images into the catalog (public/cards). Auth is enforced
  # in Backoffice::BaseController (Devise login), which also lets the internal Grover render
  # request through via a render token — so it is NOT wrapped in an `authenticate :user` block.
  namespace :backoffice do
    resources :profiles, only: %i[index edit update] do
      member do
        get   :card
        get   :card_pdf
        get   :card_png
        post  :card_preview
        get   :illustration_editor
        patch :illustration_position
        post  :render_to_catalog
      end
      collection do
        get :export_pdf
        get :export_png
        get :render_queue
      end
    end

    # Weapons and special rules are shared across the catalog, so they are edited in their own
    # right rather than inside one profile. The profile editor creates them inline (format: json).
    resources :weapons, only: %i[index new create edit update destroy]
    resources :special_rules, only: %i[index new create edit update destroy]
  end

  mount ActionCable.server => "/cable"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # TODO: replace with the backoffice dashboard once it exists.
  root to: redirect("/users/sign_in")
end
