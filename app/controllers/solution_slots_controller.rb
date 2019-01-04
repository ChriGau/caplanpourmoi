class SolutionSlotsController < ApplicationController

  before_action :set_planning, only: [:edit, :update]
  before_action :set_solution_slot, only: [:edit, :update]
  # TODO => after update... + after_create

  def edit
    @solution = @planning.chosen_solution
    authorize @solution_slot
    @users_infos = @solution_slot.slot.get_infos_to_reaffect_slot(@planning.users)
    @other_users_infos = other_skilled_users_infos
    @slot = @solution_slot.slot
    @assigned_user = User.find(@solution_slot.user_id)
    render :layout => 'no_layout'
  end

  def update
    authorize @solution_slot
    respond_to do |format|
      if @solution_slot.update(user_id: params["user_id"].to_i)
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

  def other_skilled_users_infos
    # users <> team mais sont skilled. Potential backups.
    @solution_slot.slot.get_infos_to_reaffect_slot(other_users_list).select{|u| u.values[0][:skilled] == "a" }
  end

  def other_users_list
    # users non sélectionnés pour ce planning mais qui peuvent servir de backups
    User.where.not(first_name: 'no solution').includes(:roles, :plannings, :teams) - @planning.users
  end

end
