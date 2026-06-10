require "test_helper"

class PurchaseOrderTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "creates order purchase event and delivery from cart items" do
    user = users(:one)
    cart_items = user.cart_items.includes(:product).order(:created_at).to_a

    assert_difference("Order.count", 1) do
      assert_difference("Event.where(name: 'purchase').count", 1) do
        assert_difference("ChannelEventDelivery.count", 1) do
          assert_enqueued_with(job: ChannelEventDeliveryJob) do
            PurchaseOrder.call(user:, cart_items:)
          end
        end
      end
    end

    event = Event.where(name: "purchase").order(:created_at).last
    assert_equal user, event.user
    assert_equal event.subject.total_cents, event.properties.fetch("total_cents")
    assert_equal "pending", event.channel_event_delivery.status
    assert_empty user.cart_items.reload
  end

  test "raises when cart items are empty" do
    error = assert_raises(ArgumentError) do
      PurchaseOrder.call(user: users(:one), cart_items: [])
    end

    assert_equal "cart_items must be present", error.message
  end
end
