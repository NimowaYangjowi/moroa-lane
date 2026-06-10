require "test_helper"

class ChannelIdentityDemoControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "shows identity demo board shell" do
    get channel_identity_demo_url

    assert_response :success
  end

  test "returns identity status payload" do
    get channel_identity_demo_status_url

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal users(:one).member_id, payload.dig("identity", "memberId")
    assert_equal "GET", payload.dig("requests", "userLookup", "method")
    assert_equal "POST", payload.dig("requests", "eventCreate", "method")
    assert_equal "missing", payload.dig("requests", "serverCredentials", "accessKey")
    assert payload.key?("records")
  end

  test "creates demo purchase without sending delivery" do
    users(:one).cart_items.destroy_all

    assert_difference("Order.count", 1) do
      assert_difference("Event.where(name: 'purchase').count", 1) do
        assert_difference("ChannelEventDelivery.count", 1) do
          post channel_identity_demo_purchase_url
        end
      end
    end

    assert_response :created
    payload = JSON.parse(response.body)

    assert_equal "pending", payload.dig("identity", "deliveryStatus")
    assert_equal "Purchase", payload.dig("payload", "name")
    assert_equal "purchase", payload.dig("records", "events", "name")
    assert_equal "pending", payload.dig("records", "channel_event_deliveries", "status")
  end

  test "runs latest delivery and records missing credential failure" do
    post channel_identity_demo_purchase_url

    post channel_identity_demo_delivery_url

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "failed", payload.dig("identity", "deliveryStatus")
    assert_match(/CHANNELTALK_ACCESS_KEY/, payload.dig("records", "channel_event_deliveries", "last_error"))
  end
end
