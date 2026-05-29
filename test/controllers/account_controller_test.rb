require "test_helper"

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    sign_in_as users(:one)
    get account_url
    assert_response :success
  end
end
