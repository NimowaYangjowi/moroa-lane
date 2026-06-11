require "test_helper"

class ChannelIdentityDemoSnapshotTest < ActiveSupport::TestCase
  test "builds identity payload from actual records" do
    user = users(:one)
    purchase_events_count = user.events.where(name: "purchase").count
    orders_count = user.orders.count
    deliveries_count = user.channel_event_deliveries.count
    result = PurchaseOrder.call(user:, cart_items: user.cart_items.includes(:product).to_a, enqueue_delivery: false)
    result.delivery.update!(status: "failed", last_error: "missing key")

    snapshot = ChannelIdentityDemoSnapshot.build(user:)

    assert_equal user.member_id, snapshot.dig(:identity, :memberId)
    assert_equal "failed", snapshot.dig(:identity, :deliveryStatus)
    assert_equal purchase_events_count + 1, snapshot.dig(:metrics, :purchaseEvents)
    assert_equal orders_count + 1, snapshot.dig(:metrics, :orders)
    assert_equal deliveries_count + 1, snapshot.dig(:metrics, :deliveries)
    assert_equal "Purchase", snapshot.dig(:payload, :name)
    assert_equal result.event.id, snapshot.dig(:records, :events, :id)
    assert_equal "failed", snapshot.dig(:records, :channel_event_deliveries, :status)
    assert_equal "/open/v5/users/@#{user.member_id}", snapshot.dig(:requests, :userLookup, :path)
  end

  test "tags each flow step with its identifier key role" do
    user = users(:one)

    flow = ChannelIdentityDemoSnapshot.build(user:).fetch(:flow)
    roles = flow.to_h { |step| [ step[:key], step[:keyRole] ] }

    assert_equal "input", roles["acme_user"]
    assert_equal "input", roles["member_id"]
    assert_equal "input", roles["user_api"]
    assert_equal "output", roles["mapping"]
    assert_equal "output", roles["s2s_event"]
    assert_equal "output", roles["delivery"]
  end

  test "classifies failed delivery as not_configured when credentials are missing" do
    user = users(:one)
    result = PurchaseOrder.call(user:, cart_items: user.cart_items.includes(:product).to_a, enqueue_delivery: false)
    result.delivery.update!(status: "failed", last_error: "CHANNELTALK_ACCESS_KEY is required")

    with_env("CHANNELTALK_ACCESS_KEY" => nil, "CHANNELTALK_ACCESS_SECRET" => nil) do
      snapshot = ChannelIdentityDemoSnapshot.build(user:)

      assert_equal false, snapshot.dig(:identity, :credentialsConfigured)
      assert_equal "not_configured", snapshot.dig(:identity, :deliveryState)
      # The real failure is never hidden.
      assert_equal "failed", snapshot.dig(:identity, :deliveryStatus)
      assert_equal "failed", snapshot.dig(:records, :channel_event_deliveries, :status)
    end
  end

  test "keeps real failure as failed when credentials are configured" do
    user = users(:one)
    result = PurchaseOrder.call(user:, cart_items: user.cart_items.includes(:product).to_a, enqueue_delivery: false)
    result.delivery.update!(status: "failed", last_error: "channel rejected event")

    with_env("CHANNELTALK_ACCESS_KEY" => "key", "CHANNELTALK_ACCESS_SECRET" => "secret") do
      snapshot = ChannelIdentityDemoSnapshot.build(user:)

      assert_equal true, snapshot.dig(:identity, :credentialsConfigured)
      assert_equal "failed", snapshot.dig(:identity, :deliveryState)
    end
  end

  test "reports delivery state none when there is no delivery" do
    user = users(:two)
    user.channel_event_deliveries.destroy_all

    assert_equal "none", ChannelIdentityDemoSnapshot.build(user:).dig(:identity, :deliveryState)
  end

  private

  def with_env(values)
    previous_values = values.transform_values { |_value| nil }
    values.each do |key, value|
      previous_values[key] = ENV[key]
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    yield
  ensure
    previous_values.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
