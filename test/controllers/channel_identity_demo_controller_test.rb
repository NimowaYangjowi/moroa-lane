require "test_helper"

class ChannelIdentityDemoControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "shows identity demo board shell" do
    get channel_identity_demo_url

    assert_response :success
    assert_select "h1", "memberId to userId to S2S Purchase"
    assert_select "button", "Create demo purchase"
    assert_select "button", "Run delivery now"
    assert_select "[data-status-url=?]", channel_identity_demo_status_path
    assert_select "[data-flow-list]"
    assert_select "[data-record-grid]"
    assert_select "[data-metric='purchaseEvents']"
  end

  test "returns identity status payload" do
    get channel_identity_demo_status_url

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal users(:one).member_id, payload.dig("identity", "memberId")
    assert_equal "GET", payload.dig("requests", "userLookup", "method")
    assert_equal "POST", payload.dig("requests", "eventCreate", "method")
    assert_equal "missing", payload.dig("requests", "serverCredentials", "accessKey")
    assert_equal Event.where(user: users(:one), name: "purchase").count, payload.dig("metrics", "purchaseEvents")
    assert payload.key?("records")
  end

  test "creates demo purchase without sending delivery" do
    users(:one).cart_items.destroy_all
    purchase_events_count = Event.where(user: users(:one), name: "purchase").count
    orders_count = users(:one).orders.count
    deliveries_count = users(:one).channel_event_deliveries.count

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
    assert_equal purchase_events_count + 1, payload.dig("metrics", "purchaseEvents")
    assert_equal orders_count + 1, payload.dig("metrics", "orders")
    assert_equal deliveries_count + 1, payload.dig("metrics", "deliveries")
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
