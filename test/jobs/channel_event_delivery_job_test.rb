require "test_helper"

class ChannelEventDeliveryJobTest < ActiveJob::TestCase
  class FakeDeliveryService
    class << self
      attr_accessor :called_delivery
    end

    def initialize(delivery:)
      @delivery = delivery
    end

    def call
      self.class.called_delivery = @delivery
    end
  end

  setup do
    @event = Event.create!(
      name: "purchase",
      user: users(:one),
      subject: orders(:one),
      properties: {
        order_id: orders(:one).id,
        total_cents: 3200,
        currency: "USD",
        item_count: 1,
        product_ids: [ products(:one).id ],
        product_names: [ products(:one).name ]
      },
      occurred_at: Time.current
    )
    @delivery = ChannelEventDelivery.create!(
      event: @event,
      user: users(:one),
      member_id: users(:one).member_id
    )
    FakeDeliveryService.called_delivery = nil
  end

  test "moves pending delivery to processing before sending" do
    with_delivery_service(->(delivery:) { FakeDeliveryService.new(delivery:) }) do
      ChannelEventDeliveryJob.perform_now(@delivery)
    end

    assert_equal "processing", @delivery.reload.status
    assert_equal 1, @delivery.attempts
    assert_equal @delivery, FakeDeliveryService.called_delivery
  end

  test "does not send a delivery that is already processing" do
    @delivery.update!(status: "processing")

    with_delivery_service(->(delivery:) { FakeDeliveryService.new(delivery:) }) do
      ChannelEventDeliveryJob.perform_now(@delivery)
    end

    assert_nil FakeDeliveryService.called_delivery
  end

  test "does not send a delivery after maximum attempts" do
    @delivery.update!(attempts: ChannelEventDelivery::MAX_ATTEMPTS)

    with_delivery_service(->(delivery:) { FakeDeliveryService.new(delivery:) }) do
      ChannelEventDeliveryJob.perform_now(@delivery)
    end

    @delivery.reload
    assert_equal "failed", @delivery.status
    assert_equal "Maximum ChannelTalk delivery attempts reached", @delivery.last_error
    assert_nil FakeDeliveryService.called_delivery
  end

  test "marks delivery as failed when service cannot be initialized" do
    with_delivery_service(->(delivery:) { raise "missing credentials" }) do
      ChannelEventDeliveryJob.perform_now(@delivery)
    end

    @delivery.reload
    assert_equal "failed", @delivery.status
    assert_equal "missing credentials", @delivery.last_error
  end

  private

  def with_delivery_service(factory)
    original_new = ChannelTalk::PurchaseEventDelivery.method(:new)
    ChannelTalk::PurchaseEventDelivery.define_singleton_method(:new) { |delivery:| factory.call(delivery:) }

    yield
  ensure
    ChannelTalk::PurchaseEventDelivery.define_singleton_method(:new, original_new)
  end
end
