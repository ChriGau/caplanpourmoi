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
  enum status: [:not_started, :in_progress, :with_conflicts, :complete]
  after_initialize :init

  def init
    self.status ||= :not_started
  end

  def set_status
    conflict_user_id = User.find_by(first_name: 'no solution').id

    if slots.empty?
      not_started!
    elsif slots.exists?(user_id: nil)
      in_progress!
    elsif slots.exists?(user_id: conflict_user_id)
      with_conflicts!
    else
      complete!
    end
  end
end
