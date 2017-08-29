Rails.application.routes.draw do

  devise_for :users
  root to: 'plannings#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :plannings
  resources :users, only: [:index]
  resources :roles, only: [:index, :new, :create]


end
