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
end
