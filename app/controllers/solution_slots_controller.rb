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
    # respond_to do |format|
      if @solution_slot.update(user_id: params["user_id"])
        # do not respond to html format pk sinon on a 2 PATCH requests quand on
        # clique sur le bouton du form + déclenche l'event click du fullcalendar
        # format.html { redirect_to planning_conflicts_path(@planning) }
        # format.js
        # format.json { render json: @solution_slot }
        redirect_to planning_conflicts_path(@planning)
      else
        # format.html { render :edit }
        format.js
        format.json { render json: @solution_slot.errors, status: :unprocessable_entity }
      end
    # end
  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def solution_slot_params
    params.require(:solution_slot).permit(:user_id)
  end
end
