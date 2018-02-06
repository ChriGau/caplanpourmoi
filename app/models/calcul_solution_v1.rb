# == Schema Information
#
# Table name: calcul_solution_v1s
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  slots_array         :text
#  slotgroups_array    :text
#  information         :text
#  compute_solution_id :integer
#
# Indexes
#
#  index_calcul_solution_v1s_on_compute_solution_id  (compute_solution_id)
#
# Foreign Keys
#
#  fk_rails_...  (compute_solution_id => compute_solutions.id)
#

class CalculSolutionV1 < ApplicationRecord
  belongs_to :compute_solution

  attr_accessor :planning, :calcul_arrays, :build_solutions, :solution

  def initialize(planning)
    super({})
    @planning = planning
    @no_solution_user = [User.find_by(first_name: 'no solution')]
  end

  # rubocop:disable LineLength, MethodLength, AbcSize

  def perform(compute_solutions)
    slots = planning.slots
    initialized_slots_array = initialize_slots_array(slots) # step 1
    self.calcul_arrays = CreateSlotgroupsService.new(initialized_slots_array, planning, self).perform # step 2
    puts 'CreateSlotgroupsService --> done'
    to_simulate_slotgroups_arrays = select_slotgroups_to_simulate(calcul_arrays[:slotgroups_array]) # step 3
    # step 4: go through plannings possibilities, assess them, select best solution. (2 cases)
    # there are some sg to simulate (case 1)
    if !to_simulate_slotgroups_arrays.empty?
      puts 'GoFindSolutionsV1Service --> initiated'
      build_solutions = GoFindSolutionsV1Service.new(planning, self, to_simulate_slotgroups_arrays).perform
      # step 5_case 1: mettre en mémoire la solution une solution
      puts 'GoFindSolutionsV1Service --> done. --> storing best solution'
      # Créer Solutions et SolutionSlots associées
      SaveSolutionsAndSolutionSlotsService.new(calcul_arrays[:slotgroups_array], calcul_arrays[:slots_array], planning, compute_solutions, build_solutions[:best_solution]).perform
      # update return variables
      test_possibilities = build_solutions[:test_possibilities]
      solutions_array = build_solutions[:solutions_array]
      best_solution = build_solutions[:best_solution]
      calculation_abstract = build_solutions[:calculation_abstract]
      # save calculation abstract in ComputeSolution instance
      compute_solution.save_calculation_abstract(calculation_abstract)
    else
      # 0 slotgroups to simulate (case 2)
      # créer une instance de solution
      solution_instance = create_solution(nil) # step 5 case 2
      # créer les SolutionSlots associés
      create_solution_slots_when_no_slotgroup_to_simulate # step 6 case 2
      # update return variables
      test_possibilities = nil
      solutions_array = nil
      best_solution = nil
      calculation_abstract = nil
    end

    # randomely validate one solution
    a = Solution.find_by(planning_id: planning.id)
    a.effectivity = 'chosen'
    a.save

    { calcul_arrays: calcul_arrays,
      test_possibilities: test_possibilities,
      solutions_array: solutions_array,
      best_solution: best_solution,
      calculation_abstract: calculation_abstract }
  end

  def initialize_slots_array(slots)
    slots.map(&:initialize_slot_hash)
  end

  def select_slotgroups_to_simulate(slotgroups_array)
    a = []
    slotgroups_array.each do |slotgroup|
      a << slotgroup if slotgroup.simulation_status == true
    end
    a
  end
end


