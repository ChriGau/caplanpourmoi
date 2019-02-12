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
    compute_solutions.select{ |c| c.p_list_of_slots_ids != nil && c.p_list_of_slots_ids[1..-2].split(',').collect! {|x| x.to_i} == self.slots.map(&:id) &&
      c.created_at > self.slots.map(&:updated_at).max }.sort
  end

  def outdated_compute_solutions
    compute_solutions.select{ |c| c.p_list_of_slots_ids == nil || c.p_list_of_slots_ids[1..-2].split(',').collect! {|x| x.to_i} != self.slots.map(&:id) ||
      c.created_at < self.slots.map(&:updated_at).max }.sort
  end

  def number_of_days
    # integer : nb of days where there is at least 1 slot
    nb_days = 0
    timeframe.first.each do |date|
      nb_days += 1 if slots_on_that_day?(date)
    end
    nb_days
  end

  def list_of_days
    # list of the days of a planning where >0 slots
    list = []
    timeframe.first.each do |date|
      list << date if slots_on_that_day?(date)
    end
    list
  end

  def slots_on_that_day?(date)
    # true if >0 slot on that day
    slots.where('start_at <= ? and end_at >= ?',
      DateTime.new(date.year, date.month, date.day, 24),
      DateTime.new(date.year, date.month, date.day, 0) ).count.positive?
  end

  def start_date
    Date.commercial(year, week_number, 1).beginning_of_week
  end

  def end_date
    Date.commercial(year, week_number, 1).end_of_week
  end

  def slots_availability_of_users
    # hours (float) where users are available and skilled and there are some slots
    # pour chaque slot, qui est dispo et skilled? (n)
    # n * length of slot (hours)
  end

  def total_availability_of_users
    # hours (float) where users are available within opening hours
    r = 0
    users.each do |user|
      r += user.availability_in_hours(self)
    end
    r
  end

  def get_planning_id_according_to_a_date(date)
    Planning.find_by(week_number: date.cweek, year: date.cwyear).id
  end

  def slots_total_duration
    # sum of duration of all slots of the planning (hours, decimal)
    slots.map(&:length).inject(:+)/3600
  end

  def hours_per_role
    role_hours = {}
    slots.map(&:role).uniq.each do |role|
      slots_per_role = slots.where(role_id: role.id)
      role_hours[role.id] = seconds_in_hours(slots_per_role.map{|slot| slot.end_at - slot.start_at}.reduce(:+).to_i)
    end
    role_hours
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

  def timeframe
    [get_first_date_of_a_week(year, week_number) .. get_last_date_of_a_week(year, week_number)]
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
    p [start_time .. end_time]
    return [start_time .. end_time]
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

  private

  def seconds_in_hours(seconds)
    [seconds / 3600, seconds / 60 % 60].map { |t| t.to_s.rjust(2,'0') }.join('h')
  end


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
