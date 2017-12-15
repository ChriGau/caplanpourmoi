class Solution < ApplicationRecord
  belongs_to :planning
  has_many :solution_slots
  has_many :users, through: :solution_slots
  has_many :slots, through: :solution_slots

  validates :planning_id, presence: true

  enum status: [:in_progress, :with_conflicts, :validated, :optimal, :fresh]
end
