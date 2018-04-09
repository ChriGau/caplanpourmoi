# == Schema Information
#
# Table name: solution_slots
#
#  id             :integer          not null, primary key
#  nb_extra_hours :integer
#  status         :integer
#  user_id        :integer
#  slot_id        :integer
#  solution_id    :integer
#
# Indexes
#
#  index_solution_slots_on_slot_id      (slot_id)
#  index_solution_slots_on_solution_id  (solution_id)
#  index_solution_slots_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (slot_id => slots.id)
#  fk_rails_...  (solution_id => solutions.id)
#  fk_rails_...  (user_id => users.id)
#

class SolutionSlot < ApplicationRecord
  belongs_to :solution
  belongs_to :user
  has_many :roles, through: :roles
  belongs_to :slot
  validates :solution_id, :slot_id, :user_id, presence: true
  has_one :planning, through: :solution
  has_one :role, through: :slot
  delegate :start_at, to: :slot
  delegate :end_at, to: :slot
end
