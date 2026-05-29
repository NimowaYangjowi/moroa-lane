require "test_helper"

class ChannelDebugControllerTest < ActionDispatch::IntegrationTest
  test "should show anonymous payload" do
    get channel_debug_url
    assert_response :success
  end

  test "should show member payload" do
    sign_in_as users(:one)
    get channel_debug_url
    assert_response :success
  end
end
