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
  end

  def users
    @users = User.all
  end

  def conflicts

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
