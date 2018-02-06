# == Schema Information
#
# Table name: compute_solutions
#
#  id                      :integer          not null, primary key
#  status                  :integer
#  planning_id             :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  nb_solutions            :integer
#  nb_optimal_solutions    :integer
#  nb_iterations           :integer
#  nb_possibilities_theory :integer
#  calculation_length      :decimal(, )
#  nb_cuts_within_tree     :integer
#
# Indexes
#
#  index_compute_solutions_on_planning_id  (planning_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_id => plannings.id)
#

class ComputeSolution < ApplicationRecord
  belongs_to :planning
  has_one :calcul_solution_v1, dependent: :destroy
  has_many :solutions

  enum status: [:pending, :ready, :error]
  before_create :default_status


  def default_status
    self.status = "pending"
  end

  def save_calculation_abstract(calculation_abstract)
    # stores calculation properties.
    nb_solutions = calculation_abstract[:nb_solutions]
    nb_optimal_solutions = calculation_abstract[:nb_optimal_solutions]
    nb_iterations = calculation_abstract[:nb_iterations]
    nb_possibilities_theory = calculation_abstract[:nb_possibilities_theory]
    calculation_length = calculation_abstract[:calculation_length]
    nb_cuts_within_tree = calculation_abstract[:nb_cuts_within_tree]
  end

end
