
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
    @column1 = ["create ComputeSolution",
              "start CreateSlotgroupsService",
              "end CreateSlotgroupsService",
              "start GoFindSolutionsService",
              "start pick_best_solution",
              "start SaveSolutionsAndSolutionSlotsService",
              "end SaveSolutionsAndSolutionSlotsService"]
    @column2 = ["",
                "ComputeSolution creation",
                "CreateSlotgroupsService",
                "Choice: run through branches?",
                "GoFindSolutionsService - tree exploration",
                "GoFindSolutionsService - pick best",
                "Saving of solutions"]
    @timestamps_length = get_timestamps_length(@timestamps)
  end

  private

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def get_timestamps_length(timestamps)
    # from timestamps_algo, calculate length of each block
    i = 0
    timestamps_length = []
    timestamps.each do |timestamp|
      if i.positive?
        # if diff in seconds = 0
        if timestamp[1] - timestamps[i-1][1] == 0
          b = timestamp[1].strftime("%L").to_i - timestamps[i-1][1].strftime("%L").to_i
          length = b/1000
        else # more than 1 second time difference
          length =  timestamp[1] - @timestamps[i-1][1]
        end
      else
        length = 0
      end
      timestamps_length << length
      i += 1
    end
    timestamps_length
  end
end
