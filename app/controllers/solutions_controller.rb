class SolutionsController < ApplicationController

  before_action :set_planning, only: [:change_effectivity, :show]
  before_action :set_solution, only: [:change_effectivity, :show]

  def show

  end

  def change_effectivity
    @planning.chosen_solution&.not_chosen!
    @solution.chosen!
    @planning.set_status
    redirect_back(fallback_location: planning_conflicts_path(@planning))
  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def set_solution
    @solution = Solution.find(params[:id])
  end
end