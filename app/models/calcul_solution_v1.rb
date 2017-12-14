class CalculSolutionV1 < ApplicationRecord
  attr_accessor :planning, :calcul_arrays, :build_solutions

  def initialize(planning)
    super({})
    @planning = planning
  end

  # rubocop:disable LineLength, MethodLength, AbcSize

  def perform
    slots = planning.slots
    # step_ 1
    initialized_slots_array = initialize_slots_array(slots) # => [ {} , {} ]
    # step 2
    calcul_arrays = CreateSlotgroupsService.new(initialized_slots_array, planning, self).perform
    # step 3
    to_simulate_slotgroups_arrays = select_slotgroups_to_simulate(calcul_arrays[:slotgroups_array])
    # step 4: go through plannings possibilities, assess them, select best solution.
    build_solutions = GoFindSolutionsV1Service.new(planning, self, to_simulate_slotgroups_arrays).perform
    # @build_solutions = { :test_possibilities, :solutions_array,
    #                       :solutions_array, :best_solution }
    # best_solution = hash of solutions_array.
    # step_5: transcrire la solution en un array de slots avec users solutions
    # step 6
    save_best_solution_in_our_model
    { calcul_arrays: calcul_arrays,
      test_possibilities: build_solutions[:test_possibilities],
      solutions_array: build_solutions[:solutions_array],
      best_solution: build_solutions[:best_solution],
      calculation_abstract: build_solutions[:calculation_abstract] }
  end

  def initialize_slots_array(slots)
    slots.map(&:initialize_slot_hash)
  end

  def select_slotgroups_to_simulate(slotgroups_array)
    a = []
    slotgroups_array.each do |slotgroup|
      a << slotgroup if slotgroup.simulation_status == true
    end
  end

  def save_best_solution_in_our_model
    # Créer une instance de solution

    # Créer autant d'instances de SolutionsSlots que de slots
    # pour chaque slotgroup,
      # si simulation_status = false, user = no solution
      # sinon,
        # pour les slots à simuler, assigner le user solution
        # sinon,
  end

  private

  def get_slots_related_to_a_slotgroup(slotgroup_id, slots_array)
    # => [ {:slotgroup_id, :simulation_status, :slot_instance}, {} ]
    slots_array.select { |x| x[:slotgroup_id] == slotgroup_id }
  end

  def get_slotgroup_combination(slotgroups_solutions_array, slotgroup_id)
    slotgroups_solutions_array.find { |x| x[:sg_id] == slotgroup_id }[:combination]
  end
end
