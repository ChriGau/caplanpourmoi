class UsersController < ApplicationController

  def index
    @users = User.where.not(id: User.find_by(first_name: "no solution")).order(:first_name)
  end

  # rubocop:disable AbcSize, MethodLength
  def show
    @user = User.find(params[:id])
    @constraints = @user.constraints
    @constraint_categories = Constraint.categories
    @constraints_array = get_constraints_array(@constraints)
    @role_user = RoleUser.new
    respond_to do |format|
      format.js
      format.html
    end
  end
  # rubocop:enable AbcSize, MethodLength

  def infos
    @user = User.find(params[:id])
  end

  # rubocop:disable AbcSize, MethodLength
  def dispos
    @user = User.find(params[:id])
    @planning = Planning.first
    @constraints = @user.constraints
    @constraints_array =  get_constraints_array(@constraints)
  end
  # rubocop:enable AbcSize, MethodLength

  def new
    @user = User.new
    @roles = Role.all
  end

  def user_invite
    @user = User.new(user_params)
    @roles = Role.all
    @user.password = Devise.friendly_token.first(8)
    if @user.valid?
      u = User.invite!(user_params)
      u.update(profile_picture: photo_params[:profile_picture]) if !photo_params[:profile_picture].nil?
      redirect_to users_path, notice: "#{@user.first_name} fait parti de votre entreprise"
    else
      render :new, user: @user, roles: @roles
    end
  end

  def reinvite
    @user = User.find(params[:id])
    if @user.invitation_token.nil?
      @user.invitation_token = "provional"
      @user.save
    end
    User.invite!(email: @user.email)
    redirect_to users_path, notice: "Une nième invitation a été envoyée à #{@user.first_name} !"
  end

  # def update
  #   @user = User.find(params[:id])

  #   if @user.update(user_params)
  #     redirect_to plannings_path
  #   else
  #     render :edit
  #   end
  # end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :working_hours, role_ids: [])
  end

  def photo_params
    params.require(:user).permit(:profile_picture)
  end

  def set_title
    ['Congé  annuel', 'Congé maladie', 'Préférence'].sample
  end

  def constraint_color(category)
    if category == :conge_annuel.to_s
      'blue'
    elsif category == :maladie.to_s
      'red'
    else
      'orange'
    end
  end

  def get_constraints_array(constraints)
    array = []
    constraints.each do |constraint|
      a = {
        id:  constraint.id,
        start:  constraint.start_at,
        end: constraint.end_at,
        title: constraint.category,
        created_at: constraint.created_at,
        updated_at: constraint.updated_at,
        color: constraint_color(constraint.category),
        user_id: constraint.user_id
      }
      array << a
    end
    array
  end

end
