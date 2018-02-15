# == Route Map
#
#                   Prefix Verb   URI Pattern                                      Controller#Action
#              attachinary        /attachinary                                     Attachinary::Engine
#         new_user_session GET    /users/sign_in(.:format)                         devise/sessions#new
#             user_session POST   /users/sign_in(.:format)                         devise/sessions#create
#     destroy_user_session DELETE /users/sign_out(.:format)                        devise/sessions#destroy
#        new_user_password GET    /users/password/new(.:format)                    devise/passwords#new
#       edit_user_password GET    /users/password/edit(.:format)                   devise/passwords#edit
#            user_password PATCH  /users/password(.:format)                        devise/passwords#update
#                          PUT    /users/password(.:format)                        devise/passwords#update
#                          POST   /users/password(.:format)                        devise/passwords#create
# cancel_user_registration GET    /users/cancel(.:format)                          devise/registrations#cancel
#    new_user_registration GET    /users/sign_up(.:format)                         devise/registrations#new
#   edit_user_registration GET    /users/edit(.:format)                            devise/registrations#edit
#        user_registration PATCH  /users(.:format)                                 devise/registrations#update
#                          PUT    /users(.:format)                                 devise/registrations#update
#                          DELETE /users(.:format)                                 devise/registrations#destroy
#                          POST   /users(.:format)                                 devise/registrations#create
#                     root GET    /                                                pages#home
#           planning_slots POST   /plannings/:planning_id/slots(.:format)          slots#create
#        new_planning_slot GET    /plannings/:planning_id/slots/new(.:format)      slots#new
#       edit_planning_slot GET    /plannings/:planning_id/slots/:id/edit(.:format) slots#edit
#            planning_slot GET    /plannings/:planning_id/slots/:id(.:format)      slots#show
#                          PATCH  /plannings/:planning_id/slots/:id(.:format)      slots#update
#                          PUT    /plannings/:planning_id/slots/:id(.:format)      slots#update
#          events_planning GET    /plannings/:id/events(.:format)                  plannings#events
#                plannings GET    /plannings(.:format)                             plannings#index
#                 planning GET    /plannings/:id(.:format)                         plannings#show
#                          PATCH  /plannings/:id(.:format)                         plannings#update
#                          PUT    /plannings/:id(.:format)                         plannings#update
#           planning_users GET    /plannings/:id/users(.:format)                   plannings#users
#        planning_skeleton GET    /plannings/:id/skeleton(.:format)                plannings#skeleton
#       planning_conflicts GET    /plannings/:id/conflicts(.:format)               plannings#conflicts
#                    users GET    /users(.:format)                                 users#index
#                     user GET    /users/:id(.:format)                             users#show
#                    roles GET    /roles(.:format)                                 roles#index
#                          POST   /roles(.:format)                                 roles#create
#                 new_role GET    /roles/new(.:format)                             roles#new
#               user_infos GET    /users/:id/infos(.:format)                       users#infos
#              user_dispos GET    /users/:id/dispos(.:format)                      users#dispos
#
# Routes for Attachinary::Engine:
#   cors GET  /cors(.:format) attachinary/cors#show {:format=>/json/}
#

Rails.application.routes.draw do

  mount Attachinary::Engine => "/attachinary"
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :plannings, only: [:show, :index, :update, :create] do
    resources :slots, only: [:create, :edit, :show, :update, :resolve, :new, :destroy]
    resources :compute_solutions, only: [:index, :create]
    resources :solutions, only: [:show] do
      member do
        get :change_effectivity
      end
    end
    member do
      get :events, format: :json
      get :resultevents, format: :json
    end
  end

  get 'plannings/:id/users', to: 'plannings#users', as: 'planning_users'
  get 'plannings/:id/skeleton', to: 'plannings#skeleton', as: 'planning_skeleton'
  get 'plannings/:id/conflicts', to: 'plannings#conflicts', as: 'planning_conflicts'
  resources :users, only: [:index, :show]
  resources :roles, only: [:index, :new, :create]
  get 'users/:id/infos', to: 'users#infos', as: 'user_infos'
  get 'users/:id/dispos', to: 'users#dispos', as: 'user_dispos'

  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.is_owner } do
    mount Sidekiq::Web => '/sidekiq'
  end

end
