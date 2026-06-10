require "test_helper"

module ChannelTalk
  class PurchaseEventDeliveryTest < ActiveSupport::TestCase
    class FakeClient
      attr_reader :created_events

      def initialize(channel_user_id: "channel-user-1", channel_event_id: "channel-event-1")
        @channel_user_id = channel_user_id
        @channel_event_id = channel_event_id
        @created_events = []
      end

      def get_user_by_member_id(member_id)
        { "id" => @channel_user_id, "memberId" => member_id }
      end

      def create_event(user_id:, name:, property:)
        @created_events << { user_id:, name:, property: }
        { "id" => @channel_event_id }
      end
    end

    class FailingClient
      def get_user_by_member_id(_member_id)
        raise OpenApiClient::Error, "ChannelTalk user was not found"
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
        member_id: users(:one).member_id,
        status: "processing",
        attempts: 1
      )
    end

    test "syncs channel user mapping and marks delivery as sent" do
      client = FakeClient.new

      PurchaseEventDelivery.new(delivery: @delivery, client:).call

      mapping = users(:one).reload.channel_user_mapping
      assert_equal users(:one).member_id, mapping.member_id
      assert_equal "channel-user-1", mapping.channel_user_id
      assert_not_nil mapping.synced_at
      assert_nil mapping.last_error

      created_event = client.created_events.first
      assert_equal "channel-user-1", created_event.fetch(:user_id)
      assert_equal "Purchase", created_event.fetch(:name)
      assert_equal @event.properties.fetch("order_id").to_s, created_event.fetch(:property).fetch(:orderId)
      assert_equal "USD", created_event.fetch(:property).fetch(:currency)

      @delivery.reload
      assert_equal "sent", @delivery.status
      assert_equal mapping, @delivery.channel_user_mapping
      assert_equal "channel-user-1", @delivery.channel_user_id
      assert_equal "channel-event-1", @delivery.channel_event_id
      assert_not_nil @delivery.sent_at
      assert_nil @delivery.last_error
    end

    test "marks delivery and mapping as failed when channel user lookup fails" do
      PurchaseEventDelivery.new(delivery: @delivery, client: FailingClient.new).call

      @delivery.reload
      assert_equal "failed", @delivery.status
      assert_equal "ChannelTalk user was not found", @delivery.last_error

      mapping = users(:one).reload.channel_user_mapping
      assert_equal users(:one).member_id, mapping.member_id
      assert_equal "ChannelTalk user was not found", mapping.last_error
    end
  end
end
