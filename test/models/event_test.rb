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
end
