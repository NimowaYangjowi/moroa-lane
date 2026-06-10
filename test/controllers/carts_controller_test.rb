require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    sign_in_as users(:one)
    get cart_url
    assert_response :success
    assert_select "form[action=?]", orders_path
  end
end
