class RoleUsersController < ApplicationController


  def show
  end

  def new
    @roleuser = RoleUser.new
  end

  # rubocop:disable AbcSize, MethodLength
   def create
    @user = User.find(params[:user_id])
    roleuser_model = RoleUser.new
    roleuser_model.update(user_id: @user.id, role_id: Role.find_by(name: params[:roles].first).id)
    roleuser_list = []
    if params[:roles].length > 1
      a = params[:roles].delete_at(0)
      a.each do |role|
          new_roleuser = roleuser_model.dup
          new_roleuser.user = @user
          new_roleuser.role = role
          roleuser_list << new_roleuser
      end
    else
      roleuser_list << roleuser_model
    end
    @roleusers = @user.role_users
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
    @user = User.find(params[:user_id])
    RoleUser.destroy(params[:id])
    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  # rubocop:enable AbcSize, MethodLength

  def role_users_params
    params.require(:role_users).permit(:user_id, :role_id)
  end
end
