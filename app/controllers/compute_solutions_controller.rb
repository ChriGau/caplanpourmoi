
class ComputeSolutionsController < ApplicationController
  before_action :set_planning, only: [:index, :create]

  def index
    authorize @planning
    policy_scope(@planning.compute_solutions)
    @valid_compute_solutions = @planning.valid_compute_solutions
    @outdated_compute_solutions = @planning.outdated_compute_solutions
    @solution = @planning.solutions.chosen.first
    if !@planning.slots.count.positive?
      flash.now[:alert] = "#{view_context.link_to("Ajoutez des créneaux à votre planning",
      planning_skeleton_path(@planning))}"
    end
    flash.now[:alert] = "Sélectionnez une solution" if !@planning.solutions.chosen.exists?
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
