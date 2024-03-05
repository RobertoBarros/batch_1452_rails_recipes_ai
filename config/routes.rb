Rails.application.routes.draw do
  resources :recipes
  root to: "recipes#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
