class Slot < ApplicationRecord
  belongs_to :planning, optional: true
  belongs_to :role
  belongs_to :user, optional: true
  validates :role_id, presence: true
  after_save :set_planning_status

  def self.slot_templates
    slot_templates = []
    Role.find_each do |role|
      slot_templates << Slot.new(role_id: role.id)
    end
    slot_templates
  end

  def initialize_slot_hash
    h = { slotgroup_id: nil,
          simulation_status: false,
          slot_instance: self
           }
  end

  def similar_slots
    Slot.where('planning_id = ? and start_at = ? and end_at = ? and role_id = ?',
                planning_id, start_at, end_at, role_id)
  end

private

  def set_planning_status
    planning&.set_status
  end

end
