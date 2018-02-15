class SolutionsController < ApplicationController

  before_action :set_planning, only: [:change_effectivity]
  before_action :set_solution, only: [:change_effectivity]

  def change_effectivity
    @planning.solutions.chosen.each do |solution|
      solution.not_chosen!
    end
    @solution.chosen!
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
