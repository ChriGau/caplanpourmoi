class Team < ApplicationRecord
  belongs_to :planning
  belongs_to :user
end
