class PlanningsController < ApplicationController
  before_action :set_planning, only: [:skeleton, :users, :conflicts]

  def index
    @plannings = Planning.all
    @roles = Role.all
    @users = User.all
  end

  def show

  end

  def skeleton
    @slots = @planning.slots
    @slot = Slot.new
    @slot_templates = Slot.slot_templates
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

  private

  def planning_params
    params.require(:planning).permit("user_ids" => [])
  end

  def set_planning
    @planning = Planning.find(params[:id])
  end


end
