class SolutionSlotsController < ApplicationController

  before_action :set_planning, only: [:edit, :update]

  def edit
    @solution = @planning.chosen_solution
    @solution_slot = SolutionSlot.find(params[:id])
    @users_infos = @solution_slot.slot.get_infos_to_reaffect_slot
    @slot = @solution_slot.slot
    @assigned_user = User.find(@solution_slot.user_id)
    render :layout => 'no_layout'
  end

  def update
    @solution_slot = SolutionSlot.find(params[:id])
    if @solution_slot.update(user_id: params["user_id"])
        redirect_to planning_conflicts_path(@planning)
    else
      render :edit
    end
  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def solution_slot_params
    params.require(:solution_slot).permit(:user_id)
  end
end
