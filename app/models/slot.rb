# == Schema Information
#
# Table name: slots
#
#  id          :integer          not null, primary key
#  start_at    :datetime
#  end_at      :datetime
#  planning_id :integer
#  role_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_slots_on_planning_id  (planning_id)
#  index_slots_on_role_id      (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_id => plannings.id)
#  fk_rails_...  (role_id => roles.id)
#

class Slot < ApplicationRecord
  belongs_to :planning, optional: true
  belongs_to :role
  validates :role_id, presence: true
  after_save :set_planning_status
  has_many :solution_slots, dependent: :destroy
  has_many :solutions, through: :solution_slots

  def self.slot_templates
    slot_templates = []
    Role.find_each do |role|
      slot_templates << Slot.new(role_id: role.id)
    end
    slot_templates
  end

  def initialize_slot_hash
    { slotgroup_id: nil,
      simulation_status: false,
      slot_instance: self }
  end

  def similar_slots
    Slot.where('planning_id = ? and start_at = ? and end_at = ? and role_id = ?',
               planning_id, start_at, end_at, role_id)
  end

  private

  def set_planning_status
    planning&.set_status
  end

  def self.get_chosen_solution_slot
    # for a given slot, get the instance of solution_slot which is associated to it and
    # belongs to the chosen solution
    SolutionSlot.select{ |x| x.solution.chosen? && x.slot == self }.first
  end
end
