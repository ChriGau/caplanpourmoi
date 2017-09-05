class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  def home
    redirect_to plannings_path if current_user.present?
  end
end
