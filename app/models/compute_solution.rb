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
#  team                    :text
#  p_list_of_slots_ids     :text
#  timestamps_algo         :text
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
  has_many :solutions,  -> { order(nb_extra_hours: :asc, nb_under_hours: :desc) }, dependent: :destroy
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

  def calculate_calculation_length
    # from the timestamps_algo, get total length of the algo (seconds)
    update(calculation_length: timestamps_algo.last[1] - timestamps_algo.select{ |x| x.first == "t1"}.first[1])
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

  def evaluate_nb_optimal_solutions
    # this is done when a solution_slot is updated (its user_id is modified)
    nb = self.solutions.where(nb_overlaps: 0, nb_conflicts: 0).count
    update(nb_optimal_solutions: nb)
  end

  def list_of_slots_ids
    list_of_slots_ids = planning.slots.map(&:id)
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
      if i != 0
        if self.calculation_length.nil?
          row << "no total length"
        else
          row << ((length / self.calculation_length.to_f)*100).round(3)
        end
      end
      result << row
      i += 1
    end
    return result
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
