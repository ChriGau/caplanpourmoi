class UsersController < ApplicationController

  def index
    @users = User.all
  end

  # rubocop:disable AbcSize, MethodLength
  def show
    @plannings = Planning.all.order(:week_number)
    @roles = Role.all
    @users = User.where.not(first_name: 'no solution')
    @slot_templates = Slot.slot_templates # liste des roles
    @user = User.find(params[:id])
    @planning = Planning.first
    @constraints = @user.constraints
    @constraints_array = []
    @constraints.each do |constraint|
      title = set_title
      a = {
        id:  constraint.id,
        start:  constraint.start_at,
        end: constraint.end_at,
        title: title,
        created_at: constraint.created_at,
        updated_at: constraint.updated_at,
        color: constraint_color(title),
        user_id: constraint.user_id
      }
      # construire le BASIC hashs
      @constraints_array << a
    end

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
    @constraints_array = []
    @constraints.each do |constraint|
      title = set_title
      a = {
        id:  constraint.id,
        start:  constraint.start_at,
        end: constraint.end_at,
        title: title,
        created_at: constraint.created_at,
        updated_at: constraint.updated_at,
        color: constraint_color(title),
        user_id: constraint.user_id
      }
      # construire le BASIC hashs
      @constraints_array << a
    end
  end
  # rubocop:enable AbcSize, MethodLength

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
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
    params.require(:user).permit(:first_name, :profile_picture)
  end

  def set_title
    ['Congé  annuel', 'Congé maladie', 'Préférence'].sample
  end

  def constraint_color(title)
    if title == 'Congé annuel'
      'red'
    elsif title == 'Congé maladie'
      'blue'
    else
      'orange'
    end
  end
end
