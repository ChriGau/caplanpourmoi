# == Schema Information
#
# Table name: solutions
#
#  id                  :integer          not null, primary key
#  nb_overlaps         :integer
#  nb_extra_hours      :integer
#  planning_id         :integer
#  effectivity         :integer
#  relevance           :integer
#  compute_solution_id :integer
#
# Indexes
#
#  index_solutions_on_compute_solution_id  (compute_solution_id)
#  index_solutions_on_planning_id          (planning_id)
#
# Foreign Keys
#
#  fk_rails_...  (compute_solution_id => compute_solutions.id)
#  fk_rails_...  (planning_id => plannings.id)
#

class Solution < ApplicationRecord
  belongs_to :planning
  belongs_to :compute_solution
  has_many :solution_slots, dependent: :destroy
  has_many :users, through: :solution_slots
  has_many :slots, through: :solution_slots
  has_one :calcul_solution_v1, through: :compute_solution

  validates :planning_id, presence: true

  enum effectivity: [:chosen, :not_chosen]
  enum relevance: [:optimal, :partial]

end
