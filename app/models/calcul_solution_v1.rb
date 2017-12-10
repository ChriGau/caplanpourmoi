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
    @test_possibilities = GoFindSolutionsV1Service.new(@planning, self, @calcul_slotgroups_arrays).perform[:test_possibilities]
    { calcul_arrays: @calcul_arrays, test_possibilities: @test_possibilities, solutions: @solutions_array }
  end

  def find_solutions
    perform

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
