class Slot < ApplicationRecord
  belongs_to :planning
  belongs_to :role
  belongs_to :user
end
