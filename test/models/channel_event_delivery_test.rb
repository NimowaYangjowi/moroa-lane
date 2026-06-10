require "test_helper"

class ChannelEventDeliveryTest < ActiveSupport::TestCase
  setup do
    @event = Event.create!(
      name: "purchase",
      user: users(:one),
      subject: orders(:one),
      properties: { order_id: orders(:one).id },
      occurred_at: Time.current
    )
  end

  test "validates status" do
    delivery = ChannelEventDelivery.new(
      event: @event,
      user: users(:one),
      member_id: users(:one).member_id,
      status: "ignored"
    )

    assert_not delivery.valid?
    assert_includes delivery.errors[:status], "is not included in the list"
  end

  test "prevents duplicate deliveries for one internal event" do
    ChannelEventDelivery.create!(
      event: @event,
      user: users(:one),
      member_id: users(:one).member_id
    )

    duplicate = ChannelEventDelivery.new(
      event: @event,
      user: users(:one),
      member_id: users(:one).member_id
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:event_id], "has already been taken"
  end

  test "tracks processing status for in-flight delivery" do
    delivery = ChannelEventDelivery.new(
      event: @event,
      user: users(:one),
      member_id: users(:one).member_id,
      status: "processing",
      attempts: 1
    )

    assert delivery.valid?
  end
end
