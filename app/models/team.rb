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
# Indexes
#
#  index_teams_on_planning_id  (planning_id)
#  index_teams_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_id => plannings.id)
#  fk_rails_...  (user_id => users.id)
#

class Team < ApplicationRecord
  belongs_to :planning
  belongs_to :user
end
