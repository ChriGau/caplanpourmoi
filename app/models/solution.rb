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
#  conflicts_percentage          :decimal(, )
#  fitness                       :decimal(, )
#  grade                         :decimal(, )
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

  after_create :total_over_time, :evaluate_relevance, :evaluate_nb_conflicts, :evaluate_conflicts_percentage, :evaluate_nb_users_six_consec_days_fail, :evaluate_nb_users_daily_hours_fail, :evaluate_compactness, :evaluate_nb_users_in_overtime, :evaluate_fitness
  after_create :rate_solution
  # nb_overlaps already given as a parameter when algo creates a solution

  # Note: Solution gets updated when one of its SolutionSlot is updated

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
    # { name: seconds, ... } => contractual working hours - on duty hours
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
      nb_days = employee_nb_days(employee)
      employees_nb_days[employee.first_name] = nb_days
    end
    employees_nb_days
  end

  def employee_nb_days(employee)
    # get number of days worked by an employee (integer)
    days = []
    solution_slots.where(user: employee).map do |solution_slot|
      day_number = solution_slot.start_at.strftime("%u")
      days.push(day_number) unless days.include?(day_number)
    end
    days.length
  end

  def evaluate_nb_conflicts
    nb_conflicts = solution_slots.where('user_id = ?', no_solution_user_id).count
    update(nb_conflicts: nb_conflicts)
  end

  def evaluate_conflicts_percentage
    # decimal => nb hours where conflicts / total hours planning
    nb_hours_conflicts = solution_slots.where('user_id = ?', no_solution_user_id).map(&:slot).map(&:length).inject(:+)
    nb_hours_total = solution_slots.map(&:slot).map(&:length).inject(:+)
    nb_hours_conflicts.nil? ? conflicts_percentage = 0 : conflicts_percentage = nb_hours_conflicts / nb_hours_total
    update(conflicts_percentage: conflicts_percentage)
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

  def evaluate_nb_users_six_consec_days_fail
    # => number of users who work more than 6 consecutive days
    timeframe = planning.evaluate_timeframe_to_test_nb_users_six_consec_days_fail
    nb_users = 0
    employees_involved.each do |user|
    array_of_consec_days = [] # init
      timeframe.first.each do |date|
        solution = solution_to_take_into_account(date, planning, self)
        if user.works_today?(date, solution)
          array_of_consec_days << date
        elsif array_of_consec_days.count > 6
          nb_users += 1 if consecutive_days_intersect_planning_week?(array_of_consec_days, planning)
          array_of_consec_days = [] # re init
        end
      end # on a balayé toutes les dates pour ce user
      if array_of_consec_days.count > 6 && consecutive_days_intersect_planning_week?(array_of_consec_days, planning)
        nb_users += 1
      end
    end
    update(nb_users_six_consec_days_fail: nb_users)
  end

  def evaluate_nb_users_daily_hours_fail
    # TODO /!\ le nombre d'heure max par jour est en dur (8), à ajouter aux attributs de... team?entreprise?role?
    # est prévue la liste des cas où on a un fail - peut servir + tard...
    list = []
    nb_fails = 0
    employees_involved.each do |employee|
      dates = []
      planning.timeframe.first.each do |date| # sur toutes les dates du planning
        if employee.nb_seconds_on_duty_today(date, self)/3600 > 8 # travaille > 8h?
          dates << date
          nb_fails += 1
        end
      end
      list << { employee: employee, dates: dates } unless dates.empty?
    end
    update(nb_users_daily_hours_fail: nb_fails)
  end

  def evaluate_nb_users_in_overtime
    # number of users where weekly hours > contract
    result = 0
    employees_involved.each do |employee|
      result += 1 if nb_seconds_worked(self, employee)/3600 > employee.working_hours
    end
    update(nb_users_in_overtime: nb)
  end

  def evaluate_compactness
    # integer => pour chq user, sum (nb_days_real - nb_days_theory) if real > theory
    compactness = 0
    employees_involved.each do |employee|
      nb_days_theory = (employee.working_hours/8.0).ceil
      nb_days_real = self.employee_nb_days(employee)
      compactness += (nb_days_real - nb_days_theory) if nb_days_real > nb_days_theory
    end
    update(compactness: compactness)
  end

  def evaluate_nb_users_in_overtime
    n = 0
    employees_involved.each do |employee|
      n += 1 if employee.overtime(self).positive?
    end
    update(nb_users_in_overtime: n)
  end

  def evaluate_fitness
    # |under + overtime| / hplanning, modulo deviation. ratio (295 <=> 295%)
    working_hours = users.map(&:working_hours).inject(:+).to_f
    nb_extra_hours.zero? && nb_under_hours.zero? ? fitness = 100 : fitness = ((nb_extra_hours/3600 + nb_under_hours.abs/3600) / working_hours)*100
    update(fitness: fitness.round(1).to_f)
  end

  def rate_solution
    points = 0
    # conflicts_percentage
    if conflicts_percentage == 0
      points += 10
    elsif conflicts_percentage <= 0.05
      points += 5
    elsif conflicts_percentage > 0.05 && conflicts_percentage <= 0.1
      points += 3
    end
    # 6 days rule
    points += 10 if nb_users_six_consec_days_fail == 0
    # daily hours respect
    points += 10 if nb_users_daily_hours_fail
    if fitness <= 0.02
      points += 10
    elsif fitness > 0.02 && fitness <= 0.04
      points += 7
    elsif fitness > 0.04 && fitness <= 0.06
      points += 4
    end
    # compactness
    if compactness == 0
      points += 2
    elsif compactness <= users.count
      points += 1
    end
    # turn points into grade /100
    total_points = 42.0 # points max étant doné le bareme actuel
    grade = (points / total_points * 100).round(0)
    update(grade: grade)
  end

  private

  def no_solution_user_id
    User.find_by(first_name: 'no solution').id
  end

  def consecutive_days_intersect_planning_week?(array_of_consec_days, planning)
    start_time = get_first_date_of_a_week(planning.year, planning.week_number)
    array_of_consec_days & [start_time .. start_time + 6].count.positive?
  end

  def solution_to_take_into_account(date, planning_W, examined_solution)
    if get_planning_related_to_a_date(date) == planning_W
      self
    else
      get_planning_related_to_a_date(date).chosen_solution
    end
  end

  def get_planning_related_to_a_date(date)
    Planning.find_by(year: date.year, week_number: date.cweek)
  end

end
