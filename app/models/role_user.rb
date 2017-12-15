# == Schema Information
#
# Table name: role_users
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RoleUser < ApplicationRecord
  belongs_to :role
  belongs_to :user
end
