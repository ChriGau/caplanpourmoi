# == Route Map
#
#                               Prefix Verb   URI Pattern                                                        Controller#Action
#                          attachinary        /attachinary                                                       Attachinary::Engine
#                     new_user_session GET    /users/sign_in(.:format)                                           devise/sessions#new
#                         user_session POST   /users/sign_in(.:format)                                           devise/sessions#create
#                 destroy_user_session DELETE /users/sign_out(.:format)                                          devise/sessions#destroy
#                    new_user_password GET    /users/password/new(.:format)                                      devise/passwords#new
#                   edit_user_password GET    /users/password/edit(.:format)                                     devise/passwords#edit
#                        user_password PATCH  /users/password(.:format)                                          devise/passwords#update
#                                      PUT    /users/password(.:format)                                          devise/passwords#update
#                                      POST   /users/password(.:format)                                          devise/passwords#create
#             cancel_user_registration GET    /users/cancel(.:format)                                            devise_invitable/registrations#cancel
#                new_user_registration GET    /users/sign_up(.:format)                                           devise_invitable/registrations#new
#               edit_user_registration GET    /users/edit(.:format)                                              devise_invitable/registrations#edit
#                    user_registration PATCH  /users(.:format)                                                   devise_invitable/registrations#update
#                                      PUT    /users(.:format)                                                   devise_invitable/registrations#update
#                                      DELETE /users(.:format)                                                   devise_invitable/registrations#destroy
#                                      POST   /users(.:format)                                                   devise_invitable/registrations#create
#               accept_user_invitation GET    /users/invitation/accept(.:format)                                 devise/invitations#edit
#               remove_user_invitation GET    /users/invitation/remove(.:format)                                 devise/invitations#destroy
#                  new_user_invitation GET    /users/invitation/new(.:format)                                    devise/invitations#new
#                      user_invitation PATCH  /users/invitation(.:format)                                        devise/invitations#update
#                                      PUT    /users/invitation(.:format)                                        devise/invitations#update
#                                      POST   /users/invitation(.:format)                                        devise/invitations#create
#                                 root GET    /                                                                  pages#home
#                       planning_slots POST   /plannings/:planning_id/slots(.:format)                            slots#create
#                    new_planning_slot GET    /plannings/:planning_id/slots/new(.:format)                        slots#new
#                   edit_planning_slot GET    /plannings/:planning_id/slots/:id/edit(.:format)                   slots#edit
#                        planning_slot GET    /plannings/:planning_id/slots/:id(.:format)                        slots#show
#                                      PATCH  /plannings/:planning_id/slots/:id(.:format)                        slots#update
#                                      PUT    /plannings/:planning_id/slots/:id(.:format)                        slots#update
#                                      DELETE /plannings/:planning_id/slots/:id(.:format)                        slots#destroy
#           planning_compute_solutions GET    /plannings/:planning_id/compute_solutions(.:format)                compute_solutions#index
#                                      POST   /plannings/:planning_id/compute_solutions(.:format)                compute_solutions#create
# change_effectivity_planning_solution GET    /plannings/:planning_id/solutions/:id/change_effectivity(.:format) solutions#change_effectivity
#                    planning_solution GET    /plannings/:planning_id/solutions/:id(.:format)                    solutions#show
#                      events_planning GET    /plannings/:id/events(.:format)                                    plannings#events
#                resultevents_planning GET    /plannings/:id/resultevents(.:format)                              plannings#resultevents
#                            plannings GET    /plannings(.:format)                                               plannings#index
#                                      POST   /plannings(.:format)                                               plannings#create
#                             planning GET    /plannings/:id(.:format)                                           plannings#show
#                                      PATCH  /plannings/:id(.:format)                                           plannings#update
#                                      PUT    /plannings/:id(.:format)                                           plannings#update
#                       planning_users GET    /plannings/:id/users(.:format)                                     plannings#users
#                    planning_skeleton GET    /plannings/:id/skeleton(.:format)                                  plannings#skeleton
#                   planning_conflicts GET    /plannings/:id/conflicts(.:format)                                 plannings#conflicts
#                                users GET    /users(.:format)                                                   users#index
#                                 user GET    /users/:id(.:format)                                               users#show
#                                roles GET    /roles(.:format)                                                   roles#index
#                                      POST   /roles(.:format)                                                   roles#create
#                             new_role GET    /roles/new(.:format)                                               roles#new
#                           user_infos GET    /users/:id/infos(.:format)                                         users#infos
#                          user_dispos GET    /users/:id/dispos(.:format)                                        users#dispos
#                          sidekiq_web        /sidekiq                                                           Sidekiq::Web
#                    letter_opener_web        /letter_opener                                                     LetterOpenerWeb::Engine
#
# Routes for Attachinary::Engine:
#   cors GET  /cors(.:format) attachinary/cors#show {:format=>/json/}
#
# Routes for LetterOpenerWeb::Engine:
# clear_letters DELETE /clear(.:format)                 letter_opener_web/letters#clear
# delete_letter DELETE /:id(.:format)                   letter_opener_web/letters#destroy
#       letters GET    /                                letter_opener_web/letters#index
#        letter GET    /:id(/:style)(.:format)          letter_opener_web/letters#show
#               GET    /:id/attachments/:file(.:format) letter_opener_web/letters#attachment
#

Rails.application.routes.draw do

  mount Attachinary::Engine => "/attachinary"
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :plannings, only: [:show, :index, :update, :create] do
    resources :slots, only: [:create, :edit, :show, :update, :resolve, :new, :destroy]
    resources :compute_solutions, only: [:index, :create]
    resources :solution_slots, only: [:edit, :update]
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

  resources :users, only: [:index, :show, :create, :new, :update] do
    resources :constraints, only: [:new, :create, :edit, :update, :destroy]
    resources :role_users, only: [:new, :create, :edit, :update, :destroy]
  end
  resources :roles, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  resources :colors, only: [:new, :create]
  get 'users/:id/infos', to: 'users#infos', as: 'user_infos'
  get 'users/:id/dispos', to: 'users#dispos', as: 'user_dispos'
  post 'users/user_invite', to: 'users#user_invite', as: "users_invite"
  get 'users/:id/reinvite', to: 'users#reinvite', as: "user_reinvite"
  resources :colors, only: [:new, :create]

  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.is_owner } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Letter Opener
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

end
