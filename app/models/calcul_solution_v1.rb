class CalculSolutionV1 < ApplicationRecord

  def initialize(planning)
    @planning = planning
  end

  def perform
    slots = @planning.slots
    initialized_slots_array = initialize_slots_array(slots) # get [ {} , {} ]
    slotgroups = CreateSlotgroupsService.new(initialized_slots_array, @planning).perform
    # identify overlapping slotgroups (update previous step)
    # identify overlapping users (update previous step)
    # list combinations of users per slotgroups (update previous step)
    # combine combinations
    # assess planning
    # assess solutions
  end

  def initialize_slots_array(slots)
    slots.map(&:initialize_slot_hash)
  end

  def generate_general_information_hash(planning_id)
    general_information_hash = { planning_id: planning_id }
  end

private



end
