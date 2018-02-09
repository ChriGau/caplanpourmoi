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
#  p_nb_slots              :integer
#  p_nb_hours              :string
#  p_nb_hours_roles        :text
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
  serialize :p_nb_hours_roles

  enum status: [:pending, :ready, :error]
  before_create :default_status, :planning_props

  def default_status
    self.status = "pending"
  end

  def planning_props
    planning = self.planning
    self.p_nb_slots = planning.slots.count
    self.p_nb_hours = nb_hours(planning)
    self.p_nb_hours_roles = hours_per_role(planning)
  end

  def save_calculation_abstract(calculation_abstract)
    # stores calculation properties.
    self.nb_solutions = calculation_abstract[:nb_solutions]
    self.nb_optimal_solutions = calculation_abstract[:nb_optimal_solutions]
    self.nb_iterations = calculation_abstract[:nb_iterations]
    self.nb_possibilities_theory = calculation_abstract[:nb_possibilities_theory]
    self.calculation_length = calculation_abstract[:calculation_length]
    self.nb_cuts_within_tree = calculation_abstract[:nb_cuts_within_tree]
  end

  private

  def nb_hours(planning)
    seconds = (planning.slots.map{|slot| slot.end_at - slot.start_at}.reduce(:+)).to_i
    seconds_in_hours(seconds)
  end

  def seconds_in_hours(seconds)
    [seconds / 3600, seconds / 60 % 60].map { |t| t.to_s.rjust(2,'0') }.join('h')
  end

  def hours_per_role(planning)
    role_hours = {}
    planning.slots.map(&:role).uniq.each do |role|
      slots_per_role = planning.slots.where(role_id: role.id)
      role_hours[role.name.to_sym] = seconds_in_hours(slots_per_role.map{|slot| slot.end_at - slot.start_at}.reduce(:+).to_i)
    end
    role_hours
  end
end
