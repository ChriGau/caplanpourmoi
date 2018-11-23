# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  working_hours          :integer
#  is_owner               :boolean
#  first_name             :string
#  last_name              :string
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :integer
#  invitations_count      :integer          default(0)
#
# Indexes
#
#  index_users_on_email                              (email) UNIQUE
#  index_users_on_invitation_token                   (invitation_token) UNIQUE
#  index_users_on_invitations_count                  (invitations_count)
#  index_users_on_invited_by_id                      (invited_by_id)
#  index_users_on_invited_by_type_and_invited_by_id  (invited_by_type,invited_by_id)
#  index_users_on_reset_password_token               (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :constraints, dependent: :destroy
  has_many :plannings, through: :teams
  has_many :roles, through: :role_users
  has_many :role_users, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :role_users # added back bcoz triggers 'association not found error'
  has_many :solution_slots
  has_attachment :profile_picture
  scope :active, -> { where.not(first_name: "no solution").order(:first_name) }

  def concatenate_first_and_last_name
    first_name + ' ' + last_name
  end

  def skilled?(role_id)
    roles.map(&:id).include?(role_id)
  end

  def available?(start_at, end_at)
    # true if user has no constraint during a given timeframe
    constraints.where('start_at <= ? and end_at >= ?', end_at, start_at).empty?
  end

  def availability_in_hours(planning)
    # heures d'ouverture - contraintes.
    # TODO : heures d'ouverture à renseigner par le manager VS actuellement 9h - 20h
    availability_user_hours = 11 * planning.number_of_days
    planning.list_of_days.each do |date|
      duration = 0
      start_timeframe = DateTime.new(date.year, date.month, date.day, 9)
      end_timeframe = DateTime.new(date.year, date.month, date.day, 20)
      constraints.where('start_at <= ? and end_at >= ? and category != ?',
        end_timeframe, start_timeframe, Constraint.categories['preference']).each do |constraint|
        duration = constraint_duration_according_to_timeframe(constraint, 9, 20)
        availability_user_hours -= duration
      end
    end
    availability_user_hours
  end

  def skilled_and_available?(start_at, end_at, role_id)
    skilled?(role_id) && available?(start_at, end_at)
  end

  def nb_hours_planning(planning, slot = nil)
    # get nb of hours where user is on duty. Periods = planning, day.
    solution_slots = planning.get_chosen_solution_slots_for_a_user(self)
    seconds_planning = (solution_slots.map{|sol_slot| sol_slot.end_at - sol_slot.start_at}.reduce(:+)).to_i
    unless slot.nil?
      start_of_the_day = DateTime.new(slot.start_at.year, slot.start_at.month, slot.start_at.day)
      end_of_the_day = start_of_the_day + 1
      solution_slots_day = solution_slots.select{ |x| x.start_at <= end_of_the_day && x.end_at >= start_of_the_day }
      seconds_day = (solution_slots_day.map{|sol_slot| sol_slot.end_at - sol_slot.start_at}.reduce(:+)).to_i
    end
    hours_planning = seconds_in_hours(seconds_planning)
    hours_planning_status = seconds_planning/3600 < working_hours ? true : false
    hours_day = slot.nil? ? nil : seconds_in_hours(seconds_day)
    if slot.nil?
      hours_day_status = false
    else
      hours_day_status = is_working_extra_hours_this_day?(seconds_day/3600)
    end
    { hours_planning: hours_planning,
      hours_planning_decimal: seconds_planning/3600,
      hours_planning_status: hours_planning_status,
      hours_day: hours_day,
      hours_day_decimal: seconds_day/3600,
      hours_day_status: hours_day_status }
  end

  def seconds_in_hours(seconds)
    [seconds / 3600, seconds / 60 % 60].map { |t| t.to_s.rjust(2,'0') }.join('h')
  end

  def is_on_duty?(planning, slot)
    # true if is assigned to another solution_slot intersecting this slot
    planning.chosen_solution.solution_slots.select{ |s| s.user == self &&
      s.start_at <= slot.end_at && s.end_at >= slot.start_at }.count.positive?
  end

  def works_today?(date, solution)
    # true if the user is on duty for a specific day and solution
    solution.solution_slots.select{ |s| s.user == self && s.start_at <= date.to_datetime &&
      s.end_at >= date.to_datetime + 1 }.count.positive?
  end

  def nb_seconds_on_duty_today(date, solution)
    # number of seconds during which the user is on duty (for a given solution)
    solution.solution_slots.select{ |s| s.user == self && s.start_at <= date.to_datetime + 1 &&
      s.end_at >= date.to_datetime }.map{|ss| ss.slot.end_at - ss.slot.start_at}.reduce(:+).to_i
  end

  def nb_seconds_worked(solution, user)
    solution.solution_slots.where(user: user).map{|ss| ss.slot.end_at - ss.slot.start_at}.reduce(:+).to_i
  end

  def overtime(solution)
    # overtime for a user and a solution (integer, seconds)
    seconds = nb_seconds_worked(solution, self)
    seconds - (self.working_hours * 3600)
  end

  def is_on_duty_according_to_time_period?(start_at, end_at)
    # true if user is assigned to >0 slots on a chosen solution
    SolutionSlot.select{ |s| s.solution.effectivity == 'chosen' &&
      s.start_at <= end_at && s.end_at >= start_at &&
      s.user == self }.count.positive?
  end

  def is_working_extra_hours_this_day?(on_duty_hours_decimal)
    # TODO => add attribute in user model
    on_duty_hours_decimal < 8 ? true : false
  end

  def constraint_duration_according_to_timeframe(constraint, start_hour_f, end_hour_f)
    # intersection in hours (float) between constraint & opening hours
    constraint_start_hours = constraint.start_at.hour + constraint.start_at.strftime('%M').to_i/60.to_f
    constraint_end_hours = constraint.end_at.hour + constraint.end_at.strftime('%M').to_i/60.to_f
    if constraint_start_hours <= start_hour_f && constraint_end_hours >= end_hour_f
      r = end_hour_f - start_hour_f
    elsif constraint_start_hours < start_hour_f && constraint_end_hours <= end_hour_f
      r = constraint_end_hours - start_hour_f
    elsif constraint_end_hours > end_hour_f && contraint_start_hours >= start_hour_f
      r = end_hour_f - constraint_start_hours
    elsif constraint_start_hours >= start_hour_f && constraint_end_hours <= end_hour_f
      r = constraint_end_hours - constraint_start_hours
    else
      r = "attention! cas non prévu!"
    end
    r
  end

  private

end
