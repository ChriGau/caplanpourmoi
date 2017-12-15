
class ComputeSolutionsController < ApplicationController
  before_action :set_planning, only: [:index]

  def index
    @compute_solutions = @planning.compute_solutions.order(created_at: :asc)
  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

end
