class CalculSolutionV1 < ApplicationRecord
  def initialize(planning)
    super({})
    @planning = planning
  end

  def perform
    slots = @planning.slots
    initialized_slots_array = initialize_slots_array(slots) # get [ {} , {} ]
    CreateSlotgroupsService.new(initialized_slots_array, @planning, self).perform
    # assess planning
    # assess solutions
  end

  def initialize_slots_array(slots)
    slots.map(&:initialize_slot_hash)
  end
end
