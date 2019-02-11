class UsersController < ApplicationController
  before_action :set_user, only: [:show, :infos, :personnal_constraints, :reinvite, :update]

  def index
    @users = policy_scope(User)
    authorize @users
  end

  # rubocop:disable AbcSize, MethodLength
  def show
    authorize @user
    @constraints = @user.constraints
    @constraint_categories = Constraint.categories
    @constraints_array = get_constraints_array(@constraints)
    @role_user = RoleUser.new
    @constraint = Constraint.new
    @unallocated_roles = Role.all - @user.roles
    respond_to do |format|
      format.js
      format.html
    end
  end
  # rubocop:enable AbcSize, MethodLength

  def infos
  end

  # rubocop:disable AbcSize, MethodLength
  def personnal_constraints
    authorize @user
    @planning = Planning.first
    @constraints = @user.constraints
    @constraints_array =  get_constraints_array(@constraints)
    # renders users/personnal_constraints.json.jbuilder
  end
  # rubocop:enable AbcSize, MethodLength

  def new
    @user = User.new
    authorize @user
    @roles = Role.all
  end

  def user_invite
    @user = User.new(user_params)
    authorize @user
    @roles = Role.all
    @user.password = Devise.friendly_token.first(8)
    if @user.valid?
      u = User.invite!(user_params)
      u.update(profile_picture: photo_params[:profile_picture]) if !photo_params[:profile_picture].nil?
      redirect_to users_path, notice: "#{@user.first_name} fait partie de votre entreprise"
    else
      render :new, user: @user, roles: @roles
    end
  end

  def reinvite
    if @user.invitation_token.nil?
      @user.invitation_token = "provional"
      @user.save
    end
    User.invite!(email: @user.email)
    redirect_to users_path, notice: "Une nième invitation a été envoyée à #{@user.first_name} !"
  end

  def update
    # update working hours only
    authorize @user
    if params[:user].keys[0] == "working_hours"
      if @user.update(user_params)
        redirect_to user_path(@user)
      end
      # update profile_picture only
      elsif @user.update(photo_params)
        redirect_to user_path(@user)
      # update more items
      elsif @user.update(user_params)
        redirect_to user_path(@user)
      else
        render :edit, {ressource: @user}
    end
  end

  private

  def user_params
    params.require(:user).permit(policy(User).permitted_attributes)
  end

  def photo_params
    params.require(:user).permit(policy(@user).permitted_attributes)
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

  def set_user
    @user = User.find(params[:id])
  end

end
