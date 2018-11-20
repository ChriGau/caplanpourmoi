class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  layout :set_layout

  include Pundit

  # Pundit: white-list approach.
  after_action :verify_authorized, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "Vous n'êtes pas authorisé à aller par là ;-)"
  #   redirect_to(root_path)
  # end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :profile_picture])
  end

  def set_layout
    return 'home_signin' if action_name == 'home' || controller_name == 'sessions'
  end

  # setup your host to generate the absolute url needed to load your images from the external world
  # https://www.lewagon.com/blog/setup-meta-tags-rails
  def default_url_options
    { host: ENV['HOST'] || 'localhost:3000' }
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
