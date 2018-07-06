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

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :user_id, presence: true
  validates :category, presence: true

  enum status: [:submitted, :validated, :refused]
  enum category: [:conge_annuel, :maladie, :preference]
end
