class Slot < ApplicationRecord
  belongs_to :planning
  belongs_to :role
  belongs_to :user, optional: true
  validates :role_id, presence: true


  def self.slot_templates
    slot_templates = []
    Role.all.each do |role|
      slot_templates << Slot.new(role_id: role.id)
    end
    slot_templates
  end
end
