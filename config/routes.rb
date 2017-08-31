Rails.application.routes.draw do
  mount Attachinary::Engine => "/attachinary"
  devise_for :users
  root to: 'plannings#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :plannings, only: [:show, :index, :update] do
    resources :slots, only: [:create, :edit, :show]
  end

  get 'plannings/:id/users', to: 'plannings#users', as: 'planning_users'
  get 'plannings/:id/skeleton', to: 'plannings#skeleton', as: 'planning_skeleton'
  get 'plannings/:id/conflicts', to: 'plannings#conflicts', as: 'planning_conflicts'
  resources :users, only: [:index, :show]
  resources :roles, only: [:index, :new, :create]

end
