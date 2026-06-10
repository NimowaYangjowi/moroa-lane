require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "validates supported event names" do
    event = Event.new(
      name: "checkout",
      user: users(:one),
      subject: products(:one),
      properties: { product_slug: products(:one).slug },
      occurred_at: Time.current
    )

    assert_not event.valid?
    assert_includes event.errors[:name], "is not included in the list"
  end

  test "allows purchase events for order subjects" do
    event = Event.new(
      name: "purchase",
      user: users(:one),
      subject: orders(:one),
      properties: { order_id: orders(:one).id },
      occurred_at: Time.current
    )

    assert event.valid?
  end
end
