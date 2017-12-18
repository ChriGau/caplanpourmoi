# == Schema Information
#
# Table name: solutions
#
#  id                  :integer          not null, primary key
#  calculsolutionv1_id :integer
#  nb_overlaps         :integer
#  nb_extra_hours      :integer
#  status              :integer
#  planning_id         :integer
#
# Indexes
#
#  index_solutions_on_planning_id  (planning_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_id => plannings.id)
#

class Solution < ApplicationRecord
  belongs_to :planning
  has_many :solution_slots
  has_many :users, through: :solution_slots
  has_many :slots, through: :solution_slots

  validates :planning_id, presence: true

  enum status: [:in_progress, :with_conflicts, :validated, :optimal, :fresh]
end
