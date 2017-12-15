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
