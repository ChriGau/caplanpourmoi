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
end
