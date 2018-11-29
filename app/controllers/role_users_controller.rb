class RoleUsersController < ApplicationController
  before_action :set_user, only: [:create, :destroy]
  before_action :set_role_user, only: [:destroy]

  def show
  end

  def new
    @roleuser = RoleUser.new
  end

  # rubocop:disable AbcSize, MethodLength
   def create
    roleuser_list = []
    if params[:role_ids].length > 1
      params[:role_ids].each do |role_id|
        roleuser_list << RoleUser.new(user: @user, role: Role.find(role_id))
      end
    else
      roleuser_list << RoleUser.new(user: @user, role: Role.find(params[:role_ids].first))
    end
    authorize RoleUser
    if @user.role_users << roleuser_list
      respond_to do |format|
        format.html { redirect_to user_path(@user) }
        format.js
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.js
      end
    end
  end

  def destroy
    authorize @role_user
    if @role_user.destroy
      respond_to do |format|
        format.js {render inline: "location.reload();" }
      end
    else
      redirect_to user_path(@user)
    end
  end

  # rubocop:enable AbcSize, MethodLength
  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_role_user
    @role_user = RoleUser.find(params[:id])
  end

  def role_users_params
    params.require(:role_users).permit(:user_id, :role_id)
  end
end
