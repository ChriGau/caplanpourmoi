class Slot < ApplicationRecord
  belongs_to :planning, optional:true
  belongs_to :role
  belongs_to :user, optional: true
  belongs_to :slotgroup, optional: true
  validates :role_id, presence: true
  after_save :set_planning_status


  def self.slot_templates
    slot_templates = []
    Role.all.each do |role|
      slot_templates << Slot.new(role_id: role.id)
    end
    slot_templates
  end

  def similar_slots
    # return list of slots with same start + end + role
    Slot.where(start_at: self.start_at, end_at: self.end_at, role_id: self.role_id)
  end

  def similar_slots_unassigned
    # return list of similar and unassigned slots (no slotgroup_id)
    Slot.where(start_at: self.start_at, end_at: self.end_at, role_id: self.role_id, slotgroup_id: nil)
  end

  def set_slot_simulation_status(slots)
    # determine slot simulation status
    slots.each do |slot|
      cpt_no_solutions = 0
      # skilled & available users >= required  users?
      if slot.slotgroup.nb_available >= slot.slotgroup.nb_required
        puts "blabla"
      end
    end
  end

  private

  def set_planning_status
    planning.set_status if planning
  end



end
