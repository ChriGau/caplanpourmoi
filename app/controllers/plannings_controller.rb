class PlanningsController < ApplicationController

  def index
    @plannings = Planning.all
    @roles = Role.all
    @users = User.all
  end

  def show
    @planning = Planning.find(params[:id])
    @roles = Role.all
    @slot = Slot.new
    @users = User.all
  end

  def edit
    @users = User.all
    @planning = Planning.find(params[:id])
  end

  def update
    @planning = Planning.find(params[:id])
    @planning.update(planning_params)
    @planning.save!
    redirect_to edit_planning_path(@planning)
  end

  private

  def planning_params
    params.require(:planning).permit(user_ids: [])
  end


end
