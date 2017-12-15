# == Schema Information
#
# Table name: compute_solutions
#
#  id          :integer          not null, primary key
#  status      :integer
#  planning_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_compute_solutions_on_planning_id  (planning_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_id => plannings.id)
#

class ComputeSolution < ApplicationRecord
  belongs_to :planning
  enum status: [:pending, :ready, :error]
  before_create :default_status

  def default_status
    self.status = "pending"
  end

end
