class UsersController < ApplicationController


  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
  end

  # def update
  #   @user = User.find(params[:id])

  #   if @user.update(user_params)
  #     redirect_to root_path
  #   else
  #     render :edit
  #   end
  # end


  private

  def user_params
    params.require(:user).permit(:first_name, :profile_picture)
  end

end
