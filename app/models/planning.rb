class Planning < ApplicationRecord
  has_many :teams
  has_many :slots
end
