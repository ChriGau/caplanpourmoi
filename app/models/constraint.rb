# == Schema Information
#
# Table name: constraints
#
#  id         :integer          not null, primary key
#  start_at   :datetime
#  end_at     :datetime
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  category   :integer
#  status     :integer
#
# Indexes
#
#  index_constraints_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Constraint < ApplicationRecord
  belongs_to :user
end
