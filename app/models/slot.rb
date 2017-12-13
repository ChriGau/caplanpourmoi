# == Schema Information
#
# Table name: slots
#
#  id          :integer          not null, primary key
#  start_at    :datetime
#  end_at      :datetime
#  planning_id :integer
#  role_id     :integer
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Slot < ApplicationRecord
  belongs_to :planning, optional: true
  belongs_to :role
  belongs_to :user, optional: true
  belongs_to :slotgroup, optional: true
  validates :role_id, presence: true
  after_save :set_planning_status

  def self.slot_templates
    slot_templates = []
    Role.find_each do |role|
      slot_templates << Slot.new(role_id: role.id)
    end
    slot_templates
  end

  private

  def set_planning_status
    planning&.set_status
  end
end
