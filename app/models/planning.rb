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

  enum status: [:not_started, :in_progress, :with_conflicts, :complete]
  after_initialize :init

  def init
    self.status ||= :not_started
  end

  def set_status
    if slots.empty?
      not_started!
    elsif solutions.exists?(status: "validated")
      complete!
    elsif solutions.exists?(status: "with_conflicts")
      with_conflicts!
    else
      in_progress!
    end
  end
end
