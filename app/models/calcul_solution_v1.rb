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
  serialize :slotgroups_array
  serialize :slots_array

  attr_accessor :planning, :calcul_arrays, :build_solutions, :solution

  def initialize(planning)
    super({})
    @planning = planning
    @no_solution_user = User.find_by(first_name: 'no solution')
  end

  # rubocop:disable LineLength, MethodLength, AbcSize

  def perform(compute_solution)
    slots = planning.slots
    # initialize return variables
    test_possibilities = nil
    solutions_array = nil
    best_solution = nil
    calculation_abstract = nil
    initialized_slots_array = initialize_slots_array(slots) # step 1

    CreateSlotgroupsService.new(slots_array: initialized_slots_array,
                                planning: planning,
                                calcul_solution_v1_instance: self).perform # step 2
    slots_not_to_simulate = get_slots_not_to_simulate(slotgroups_array, initialized_slots_array)
    to_simulate_slotgroups_array = select_slotgroups_to_simulate(self.slotgroups_array) # step 3
    need_a_calcul = to_simulate_slotgroups_array.empty? ? false : true
    if need_a_calcul # there are some sg to simulate (case 1)
      # step 4: go through plannings possibilities, assess them, select best solution. (2 cases)
      puts 'GoFindSolutionsV1Service --> initiated'
      build_solutions = GoFindSolutionsV1Service.new(planning: planning,
                                                     slotgroups_array: to_simulate_slotgroups_array,
                                                     compute_solution: self.compute_solution).perform
      # build_solutions = [ {calculation_abstract}, [ [:sg_id, :combination], [...] ] ]
      puts 'GoFindSolutionsV1Service --> done. --> storing best solution'
      calculation_abstract = build_solutions[0]
      # save calculation abstract in ComputeSolution instance
      compute_solution.save_calculation_abstract(calculation_abstract)
    end
    # Créer Solutions et SolutionSlots associées
    list_of_solutions = need_a_calcul ? build_solutions[1] : nil
    SaveSolutionsAndSolutionSlotsService.new( slotgroups_array: self.slotgroups_array,
                                              slots_array: self.slots_array,
                                              planning: planning,
                                              compute_solution: compute_solution,
                                              list_of_solutions: list_of_solutions,
                                              slots_not_to_simulate: slots_not_to_simulate ).perform
    puts 'SaveSolutionsAndSolutionSlotsService --> done'
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

  def evaluate_nb_conflicts_for_a_group_of_solutions(solutions_array)
    solutions_array.each do |solution|
      solution.solution_slots.each do |solution_slot|
        if solution_slot.user_id == determine_no_solution_user.id
          if !solution.nb_conflicts.nil?
            solution.nb_conflicts = 1
          else
            solution.nb_conflicts += 1
          end
        end
      end
    end
  end

  def determine_no_solution_user
    User.find_by(first_name: 'no solution')
  end

  def update_relevance(solutions_array)
    solutions_array.each do |solution|
      solution.evaluate_relevance
    end
  end

  def get_slots_not_to_simulate(slotgroups_array, initialized_slots_array)
    # put aside all the slots which do not need a calcul (no solution)
    # pour pouvoir créer les solution_slots associés à no_solution
    r = []
    slotgroups_array.select{ |x| x.simulation_status == false }.each do |slotgroup|
      r << similar_slots(slotgroup.id, initialized_slots_array).map{ |h| h[:slot_id] }
    end
    r.flatten
  end

  def similar_slots(slotgroup_id, initialized_slots_array)
    initialized_slots_array.select { |x| x[:slotgroup_id] == slotgroup_id }
  end
end


