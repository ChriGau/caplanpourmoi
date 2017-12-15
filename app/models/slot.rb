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
# Indexes
#
#  index_slots_on_planning_id  (planning_id)
#  index_slots_on_role_id      (role_id)
#  index_slots_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_id => plannings.id)
#  fk_rails_...  (role_id => roles.id)
#  fk_rails_...  (user_id => users.id)
#

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
