Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  resources :devices, only: [ :index, :edit, :update, :destroy ] do
    scope module: :devices do
      resource  :status,            only: :show
      resources :commands,          only: :create
      resource  :version_detection, only: :create
    end
  end
  resources :schedules, only: %i[index create update destroy]
  root "devices#index"
end
