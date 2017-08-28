Rails.application.routes.draw do
  get 'teams/new'

  get 'teams/create'

  get 'teams/edit'

  get 'teams/update'

  get 'roles/new'

  get 'roles/create'

  get 'roles/edit'

  get 'roles/update'

  get 'roles/destroy'

  devise_for :users
  root to: 'plannings#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :plannings do
    resources :teams, only: [:new, :create, :edit, :update]
  end
  resources :users, only: [:index]
  resources :roles, only: [:index, :new, :create]


end
