class PlanningsController < ApplicationController
  before_action :set_planning, only: [:skeleton, :users, :conflicts, :events]

  def index
    @plannings = Planning.all.order(:week_number)
    @roles = Role.all
    @users = User.where.not(first_name: "no solution")
    @slot_templates = Slot.slot_templates # liste des roles
  end

  def show
  end

  def skeleton
    @planning = Planning.find(params[:id])
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles
    @url = "skeleton"
  end

  def conflicts
    @planning = Planning.find(params[:id])
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles
    # modifier 1 slot mécano du  mercredi 13/9 en "no solution"
    # guersbru : le dit slot n'a pas toujours l'id 887... ça crash je commente la ligne
    # Slot.find(887).user_id = "no solution"
    @url = "conflicts"
    # variables pour fullcalendar
    @slots_array = []
    @slots.each do |slot|
    @user = current_user
    a= {
      id:  slot.id,
      start:  slot.start_at,
      end: slot.end_at,
      title: Role.find_by_id(slot.role_id).name, # nom du role
      role_id: slot.role_id, # nom du role
      created_at: slot.created_at,
      updated_at: slot.updated_at,
      color: Role.find_by_id(slot.role_id).role_color,
      planning_id: slot.planning_id,
      user_id: User.find(slot.user_id).id,
      picture: User.find(slot.user_id).profile_picture
       }
      @slots_array << a
    end
  end

  def users
    @users = User.all
    @url = "users"
  end

  def update
    @planning = Planning.find(params[:id])
    @planning.update(planning_params)
    @planning.save!
    redirect_to planning_users_path(@planning)
  end


  def events
    # json only request for fullcalendar
    # render events.json.jbuilder
  end

  private

  def planning_params
    params.require(:planning).permit("user_ids" => [])
  end

  def set_planning
    @planning = Planning.find(params[:id])
  end
end
