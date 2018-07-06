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

  def start_date
    Date.commercial(year, week_number, 1).beginning_of_week
  end

  def end_date
    Date.commercial(year, week_number, 1).end_of_week
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

  private

  def seconds_in_hours(seconds)
    [seconds / 3600, seconds / 60 % 60].map { |t| t.to_s.rjust(2,'0') }.join('h')
  end

end
