class CalculSolutionV1 < ApplicationRecord
  def initialize(planning)
    super({})
    @planning = planning
  end

  def perform
    slots = @planning.slots
    initialized_slots_array = initialize_slots_array(slots) # get [ {} , {} ]
    @calcul_arrays = CreateSlotgroupsService.new(initialized_slots_array, @planning, self).perform
    # select only slotgroups to simulate => inject into GoFindSolutionsService
    @calcul_slotgroups_arrays = select_slotgroups_to_simulate(@calcul_arrays[:slotgroups_array])
    # go through plannings possibilities, assess them, select them.
    @build_solutions = GoFindSolutionsV1Service.new(@planning, self, @calcul_slotgroups_arrays).perform
    # @build_solutions = { test_possibilities: test_possibilities, solutions_array: solutions_array, best_solution: best_solution }
    # best_solution = hash of solutions_array.
    { calcul_arrays: @calcul_arrays,
      test_possibilities: @build_solutions[:test_possibilities],
      solutions_array: @build_solutions[:solutions_array],
      best_solution: @build_solutions[:best_solution] }
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
end
