require 'test_helper'

class SolutionsControllerTest < ActionDispatch::IntegrationTest
  test "should get change_effectivity" do
    get solutions_change_effectivity_url
    assert_response :success
  end

end
