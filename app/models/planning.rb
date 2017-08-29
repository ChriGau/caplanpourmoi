class Planning < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :users, through: :teams
  has_many :slots
end
