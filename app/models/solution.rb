# == Schema Information
#
# Table name: solutions
#
#  id                            :integer          not null, primary key
#  nb_overlaps                   :integer
#  nb_extra_hours                :integer
#  planning_id                   :integer
#  compute_solution_id           :integer
#  effectivity                   :integer          default("not_chosen")
#  relevance                     :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  nb_conflicts                  :integer
#  nb_under_hours                :integer
#  nb_users_six_consec_days_fail :integer
#  nb_users_daily_hours_fail     :integer
#  compactness                   :integer
#  nb_users_in_overtime          :integer
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

  enum effectivity: [:not_chosen, :chosen]
  enum relevance: [:optimal, :partial]

  # Note: Solution get updated when one of its SolutionSlot is saved

  def evaluate_relevance
    nb_conflicts = solution_slots.where(user: User.find_by(first_name: 'no solution')).count
    relevance = !nb_conflicts.nil? && nb_conflicts.zero? ? :optimal : :partial
    update(relevance: relevance, nb_conflicts: nb_conflicts)
  end


  def employees_involved
    solution_slots.map(&:user).uniq
  end

  def employees_names
    employees_involved.pluck(:first_name).reject{|name| name == "no solution"}
  end

  def employees_overtime
    employees_overtime = {}
    employees_involved.each do |employee|
      seconds = self.solution_slots.where(user: employee).map{|ss| ss.slot.end_at - ss.slot.start_at}.reduce(:+).to_i
      employees_overtime[employee.first_name.capitalize] = seconds - (employee.working_hours * 3600)
    end
    employees_overtime
  end

  def total_over_time
    overtime = undertime = 0
    employees_overtime.values.each do |value|
      overtime += value if value > 0
      undertime += value if value < 0
    end
    update(nb_extra_hours: overtime, nb_under_hours: undertime)
  end

  def employees_nb_days
    employees_nb_days = {}
    employees_involved.each do |employee|
      days = []
      solution_slots.where(user: employee).map do |solution_slot|
        day_number = solution_slot.start_at.strftime("%u")
        days.push(day_number) unless days.include?(day_number)
      end
      employees_nb_days[employee.first_name] = days.length
    end
    employees_nb_days
  end

  def evaluate_nb_conflicts
    nb_conflicts = solution_slots.where('user_id = ?', no_solution_user_id).count
    update(nb_conflicts: nb_conflicts)
  end

  def evaluate_nb_overlaps
    # overlap = a user who must be at >1 places at once. User <> 'no solution'.
    nb_overlaps = 0
    overlaps_full_details = []
    list_of_solution_slots = solution_slots.where('user_id != ?', no_solution_user_id)
    list_of_solution_slots.each do |solution_slot|
      result = solution_slot.evaluate_overlaps_for_a_solution_slot
      if result[:nb_overlaps] > 0
        nb_overlaps += result[:nb_overlaps]
        overlaps_full_details << result[:overlaps_details]
      end
    end
    update(nb_overlaps: nb_overlaps/2)
    { nb_overlaps: nb_overlaps, overlaps_details: overlaps_full_details }
  end

  private

  def no_solution_user_id
    User.find_by(first_name: 'no solution').id
  end
end
