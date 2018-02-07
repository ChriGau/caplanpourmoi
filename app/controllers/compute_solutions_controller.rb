
class ComputeSolutionsController < ApplicationController
  before_action :set_planning, only: [:index, :create]

  def index
    @compute_solutions = @planning.compute_solutions.order(created_at: :desc)
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
