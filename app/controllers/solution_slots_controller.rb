class SolutionSlotsController < ApplicationController

  before_action :set_planning, only: [:edit, :update]
  before_action :set_solution_slot, only: [:edit, :update]
  # TODO => after update... + after_create

  def edit
    @solution = @planning.chosen_solution
    authorize @solution_slot
    @users_infos = @solution_slot.slot.get_infos_to_reaffect_slot
    @slot = @solution_slot.slot
    @assigned_user = User.find(@solution_slot.user_id)
    render :layout => 'no_layout'
  end

  def update
    authorize @solution_slot
    respond_to do |format|
      if @solution_slot.update(user_id: params["user_id"])
          format.js
      else
        render :edit
      end
    end
  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def solution_slot_params
    params.require(:solution_slot).permit(:user_id)
  end

  def set_solution_slot
    @solution_slot = SolutionSlot.find(params[:id])
  end
end
