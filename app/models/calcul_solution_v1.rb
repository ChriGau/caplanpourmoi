# == Schema Information
#
# Table name: calcul_solution_v1s
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  slots_array      :text
#  slotgroups_array :text
#  information      :text
#

class CalculSolutionV1 < ApplicationRecord

  def initialize(planning)
    super({})
    @planning = planning
  end

  def perform
    slots = @planning.slots
    initialized_slots_array = initialize_slots_array(slots) # get [ {} , {} ]
    slotgroups = CreateSlotgroupsService.new(initialized_slots_array, @planning, self).perform
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

end
