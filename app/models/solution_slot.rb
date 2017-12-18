class SolutionSlot < ApplicationRecord
  belongs_to :solution, dependent: :destroy
  belongs_to :user
  has_many :roles, through: :roles
  belongs_to :slot, dependent: :destroy
  validates :solution_id, :slot_id, :user_id, presence: true
  has_one :planning, through: :solution
  has_one :role, through: :slot
end
