# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  planning_id :integer
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Team < ApplicationRecord
  belongs_to :planning
  belongs_to :user
end
