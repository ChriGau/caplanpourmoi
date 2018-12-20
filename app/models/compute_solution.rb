# == Schema Information
#
# Table name: compute_solutions
#
#  id                                      :integer          not null, primary key
#  status                                  :integer
#  planning_id                             :integer
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  nb_solutions                            :integer
#  nb_optimal_solutions                    :integer
#  nb_iterations                           :integer
#  nb_possibilities_theory                 :integer
#  calculation_length                      :decimal(, )
#  nb_cuts_within_tree                     :integer
#  p_nb_slots                              :integer
#  p_nb_hours                              :string
#  p_nb_hours_roles                        :text
#  team                                    :text
#  p_list_of_slots_ids                     :text
#  timestamps_algo                         :text
#  go_through_solutions_mean_time_per_slot :float
#  solution_storing_mean_time_per_slot     :float
#  mean_time_per_slot                      :float
#  fail_level                              :text
#  percent_tree_covered                    :float
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
  has_one :calcul_solution_v1
  has_many :solutions, -> { order(grade: :desc) }, dependent: :destroy
  serialize :p_nb_hours_roles
  serialize :team, Hash
  serialize :timestamps_algo, Array

  enum status: [:pending, :ready, :error]
  before_create :default_status, :planning_props, :build_team

  def default_status
    self.status = "pending"
  end

  def sorted_solutions
    solutions.sort_by {|x| x.created_at }
  end

  def planning_props
    planning = self.planning
    self.p_nb_slots = planning.slots.count
    self.p_nb_hours = nb_hours(planning)
    self.p_nb_hours_roles = hours_per_role(planning)
    self.p_list_of_slots_ids = list_of_slots_ids
  end

  def build_team
    team = Hash.new {|hash,key| hash[key] = [] }
    self.planning.users.each do |user|
      user.roles.each do |role|
        team[role.id.to_s.to_sym] << user.first_name.capitalize
      end
    end
    self.team = team
  end

  def evaluate_statistics
    # go_through_solutions_mean_time_per_slot (seconds) => (T5 - T4) / nbslots
    # solution_storing_mean_time_per_slot (seconds) => (T7 - T6) / nbslots
    # mean_time_per_slot (seconds) = (T7 - T1) / nbslots
    # %tree_covered (float) = nb_iterations / nb_possibilities_theory
    unless timestamps_algo.length < 7
      nb_slots = planning.slots.count
      a = (timestamps_algo[4][1] - timestamps_algo[3][1]) / nb_slots
      b = (timestamps_algo[6][1] - timestamps_algo[5][1]) / nb_slots
      calculate_calculation_length
      c = calculation_length / nb_slots
      # si need_a_calcul = false => d = 0
      nb_iterations.nil? ? d = 0 : d = nb_iterations / nb_possibilities_theory
      update(solution_storing_mean_time_per_slot: a,
        go_through_solutions_mean_time_per_slot: b,
        mean_time_per_slot: c,
        percent_tree_covered: d)
    else
      calculate_fail_level
    end
  end

  def calculate_calculation_length
    # from the timestamps_algo, get total length of the algo (seconds)
      update(calculation_length: timestamps_algo.last[1] - timestamps_algo.first[1])
  end

  def save_calculation_abstract(calculation_abstract)
    # stores calculation properties.
    self.nb_solutions = calculation_abstract[:nb_solutions]
    self.nb_optimal_solutions = calculation_abstract[:nb_optimal_solutions]
    self.nb_iterations = calculation_abstract[:nb_iterations]
    self.nb_possibilities_theory = calculation_abstract[:nb_possibilities_theory]
    # commented because = 'todo' at this stage
    # self.calculation_length = calculation_abstract[:calculation_length]
    self.nb_cuts_within_tree = calculation_abstract[:nb_cuts_within_tree]
  end

  def evaluate_nb_optimal_solutions
    # this is done when a solution_slot is updated (its user_id is modified)
    nb = self.solutions.where(nb_overlaps: 0, nb_conflicts: 0).count
    update(nb_optimal_solutions: nb)
  end

  def list_of_slots_ids
    list_of_slots_ids = planning.slots.map(&:id)
  end

  def calculate_fail_level
    # => t# if fail occurs (text)
    unless self.timestamps_algo.empty?
      update(fail_level: self.timestamps_algo.last[0])
    end
  end

  def get_timestamps_details
    result = []
    i = 0
    self.timestamps_algo.each do |timestamp|
      row = []
      # timestamp
      row << timestamp[1].strftime("%k:%M:%S:%L")
      # length (sec)
      if i != 0
        if timestamp[1] - self.timestamps_algo[i-1][1] == 0
          b = timestamp[1].strftime("%L").to_i - self.timestamps_algo[i-1][1].strftime("%L").to_i
          "0." + b.round(4).to_s
          length = b/1000
        else
          (timestamp[1] - self.timestamps_algo[i-1][1]).round(4)
          length = timestamp[1] - self.timestamps_algo[i-1][1]
        end
        row << length.round(4)
      end
      # length//start (sec)
      if i != 0
        # si diff en seconds = 0 => calculate diff in milliseconds
        if timestamp[1] - self.timestamps_algo[0][1] == 0
          a = timestamp[1].strftime("%L").to_i -  self.timestamps_algo[0][1].strftime("%L").to_i
          row << "0." + a.round(4).to_s
        else
          row << (timestamp[1] - self.timestamps_algo[0][1]).round(4)
        end
      end
      # %total length
      unless i == 0
        self.calculation_length.nil? ? row << "no total length" : row << ((length / self.calculation_length.to_f)*100).round(3)
      end
      result << row
      i += 1
    end
    return result
  end

  def build_row_for_statistics_display
    row = [id, planning.week_number, self.planning.slots.count, self.planning.users.count]
    self.calculation_length.nil? ? row.insert(2, 0) : row.insert(2, self.calculation_length.to_f.round(4))
    timestamps_algo.length == 7 ? row.insert(3, 10) : row.insert(3, 0)
    nb_iterations.nil? ? row.insert(row.length, 0) : row.insert(row.length, nb_iterations)
    percent_tree_covered.nil? ? row.insert(row.length, 0) : row.insert(row.length, percent_tree_covered.round(3)*100)
  end

  private

  def nb_hours(planning)
    seconds = (planning.slots.map{|slot| slot.end_at - slot.start_at}.reduce(:+)).to_i
    seconds_in_hours(seconds)
  end

  def hours_per_role(planning)
    role_hours = {}
    planning.slots.map(&:role).uniq.each do |role|
      slots_per_role = planning.slots.where(role_id: role.id)
      role_hours[role.id] = seconds_in_hours(slots_per_role.map{|slot| slot.end_at - slot.start_at}.reduce(:+).to_i)
    end
    role_hours
  end

  def seconds_in_hours(seconds)
    [seconds / 3600, seconds / 60 % 60].map { |t| t.to_s.rjust(2,'0') }.join('h')
  end
end
