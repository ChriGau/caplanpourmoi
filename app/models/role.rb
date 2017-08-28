class Role < ApplicationRecord
  has_many :users, through: :role_users
end
