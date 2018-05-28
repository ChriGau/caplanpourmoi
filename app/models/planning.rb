# == Schema Information
#
# Table name: plannings
#
#  id          :integer          not null, primary key
#  week_number :integer
#  year        :integer
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Planning < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :users, through: :teams
  has_many :slots, dependent: :destroy
  has_many :compute_solutions, dependent: :destroy
  has_many :solutions, dependent: :destroy
  has_many :solution_slots, through: :solutions
  has_many :roles, -> { distinct }, through: :slots

  enum status: [:not_started, :in_progress, :with_conflicts, :complete]
  after_initialize :init

  def init
    self.status ||= :not_started
  end

  def chosen_solution
    solutions.find_by(effectivity: :chosen)
  end

  def has_a_chosen_solution?
    solutions.select{ |s| s.effectivity == :chosen }.count.positive?
  end

  def chosen_solution_slots
    chosen_solution.solution_slots
  end

  def get_chosen_solution_slots_for_a_user(user)
    chosen_solution_slots.where('user_id = ?', user.id)
  end

  def valid_compute_solutions
    compute_solutions.where('created_at > ?', self.slots.map(&:updated_at).max).order(created_at: :desc)
  end

  def outdated_compute_solutions
    compute_solutions.where('created_at < ?', self.slots.map(&:updated_at).max).order(created_at: :desc)
  end

  def set_status
    if slots.empty?
      not_started!
    elsif !chosen_solution.nil? && chosen_solution&.optimal?
      complete!
    elsif !chosen_solution.nil? && chosen_solution&.partial?
      with_conflicts!
    else
      in_progress!
    end
  end

  def get_previous_week_planning
    # => id du planning de la semaine précédente
    if week_number == 1
      Planning.find_by(year: year - 1, week_number: get_latest_week_number_of_a_year(year - 1))
    else
      Planning.find_by(year: year, week_number: week_number)
    end
  end

  def get_next_week_planning
    # => id du planning de la semaine suivante
    if week_number == get_latest_week_number_of_a_year(year)
      Planning.find_by(year: year + 1, week_number: 1)
    else
      Planning.find_by(year: year, week_number: week_number + 1)
    end
  end

  def evaluate_timeframe_to_test_nb_users_six_consec_days_fail

    if !get_previous_week_planning.nil? && get_previous_week_planning.has_a_chosen_solution?
      if !get_next_week_planning.nil? && get_next_week_planning.has_a_chosen_solution?
        start_time = get_first_date_of_a_week(get_previous_week_planning.year,
          get_previous_week_planning.week_number)
        end_time = get_last_date_of_a_week(get_next_week_planning.year,
          get_next_week_planning.week_number)
      else
        start_time = get_first_date_of_a_week(get_previous_week_planning.year,
          get_previous_week_planning.week_number)
        end_time = get_last_date_of_a_week(planning.year, planning.week_number)
      end
    elsif !get_next_week_planning.nil? && get_next_week_planning.has_a_chosen_solution?
      start_time = get_first_date_of_a_week(year, week_number)
      end_time = get_last_date_of_a_week(get_next_week_planning.year,
          get_next_week_planning.week_number)
    else
      start_time = get_first_date_of_a_week(year, week_number)
      end_time = get_last_date_of_a_week(year, week_number)
    end
    return [start_time .. end_time]
  end

  def timeframe
    [get_first_date_of_a_week(year, week_number) .. get_last_date_of_a_week(year, week_number)]

  end

  private

  def get_latest_week_number_of_a_year(year)
    Planning.where('year = ?', year).map(&:week_number).max
  end

  def get_first_date_of_a_week(year, week_number)
    Date.commercial(year, week_number, 1).beginning_of_week
  end

  def get_last_date_of_a_week(year, week_number)
    Date.commercial(year, week_number, 1).end_of_week
  end

end
