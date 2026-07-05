Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "diagnoses#new"
  resources :diagnoses, only: [ :create ]
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"
end
