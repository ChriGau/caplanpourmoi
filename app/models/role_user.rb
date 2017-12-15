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
# Indexes
#
#  index_role_users_on_role_id  (role_id)
#  index_role_users_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#  fk_rails_...  (user_id => users.id)
#

class RoleUser < ApplicationRecord
  belongs_to :role
  belongs_to :user
end
