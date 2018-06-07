
class ComputeSolutionsController < ApplicationController
  before_action :set_planning, only: [:index, :create, :show_calculation_details]
require 'uri'

  def index
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

  def show_calculation_details
    @compute_solution = ComputeSolution.find(params[:compute_solution_id])
    @timestamps = @compute_solution.timestamps_algo
    @infos = ["create ComputeSolution",
              "start CreateSlotgroupsService",
              "end CreateSlotgroupsService",
              "start GoFindSolutionsService",
              "start pick_best_solution",
              "start SaveSolutionsAndSolutionSlotsService",
              "end SaveSolutionsAndSolutionSlotsService"]
    # raise
  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

end
