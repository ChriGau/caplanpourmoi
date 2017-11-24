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

  private

  def set_planning_status
    planning.set_status if planning
  end
end
