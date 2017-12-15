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
#

class Constraint < ApplicationRecord
  belongs_to :user
end
