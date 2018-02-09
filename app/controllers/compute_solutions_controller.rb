
class ComputeSolutionsController < ApplicationController
  before_action :set_planning, only: [:index, :create]

  def index
    @valid_compute_solutions = @planning.valid_compute_solutions
    @outdated_compute_solutions = @planning.outdated_compute_solutions
  end

  def create
    compute_solution = ComputeSolution.create(planning_id: @planning.id)
    ComputePlanningSolutionsJob.perform_later(@planning, compute_solution)
    redirect_to planning_compute_solutions_path(@planning)

  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

end
