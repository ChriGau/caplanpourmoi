class SolutionsController < ApplicationController

  before_action :set_planning, only: [:change_effectivity, :show]
  before_action :set_solution, only: [:change_effectivity, :show]

  def show
    authorize @solution
    @roles = Role.all
  end

  def change_effectivity
    authorize @solution
    @planning.chosen_solution&.not_chosen!
    @solution.chosen!
    @planning.set_status
    redirect_to planning_conflicts_path(@planning)
  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def set_solution
    @solution = Solution.find(params[:id])
  end
end
