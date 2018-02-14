# == Schema Information
#
# Table name: slots
#
#  id          :integer          not null, primary key
#  start_at    :datetime
#  end_at      :datetime
#  planning_id :integer
#  role_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_slots_on_planning_id  (planning_id)
#  index_slots_on_role_id      (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_id => plannings.id)
#  fk_rails_...  (role_id => roles.id)
#

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should have a role_id" do
    slot = slots(:two_hours)
    assert slot.save
  end


  test "should have end date and start date" do
    slot = slots(:two_hours)
    assert slot.save, "Slot should have a start_datetime and end_datetime"
  end


end
