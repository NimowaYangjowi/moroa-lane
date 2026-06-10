module ChannelTalk
  class PurchaseEventDelivery
    EVENT_NAME = "Purchase".freeze

    def initialize(delivery:, client: OpenApiClient.from_env)
      @delivery = delivery
      @client = client
    end

    def call
      mapping = sync_channel_user_mapping
      channel_event = client.create_event(
        user_id: mapping.channel_user_id,
        name: EVENT_NAME,
        property: channel_property
      )

      delivery.mark_sent!(
        channel_user_mapping: mapping,
        channel_user_id: mapping.channel_user_id,
        channel_event_id: channel_event.fetch("id")
      )
    rescue StandardError => error
      record_mapping_error(error)
      delivery.mark_failed!(error.message)
    end

    private

    attr_reader :delivery, :client

    def sync_channel_user_mapping
      mapping = ChannelUserMapping.find_or_initialize_by(user: delivery.user)
      mapping.member_id = delivery.member_id
      mapping.save! if mapping.new_record? || mapping.changed?

      return mapping if mapping.channel_user_id.present?

      channel_user = client.get_user_by_member_id(delivery.member_id)
      channel_user_id = channel_user.fetch("id")
      mapping.update!(
        channel_user_id:,
        synced_at: Time.current,
        last_error: nil
      )
      mapping
    rescue StandardError => error
      mapping.update!(last_error: error.message) if mapping&.persisted?
      raise
    end

    def channel_property
      properties = delivery.event.properties

      {
        orderId: properties.fetch("order_id").to_s,
        totalCents: properties.fetch("total_cents"),
        currency: properties.fetch("currency"),
        itemCount: properties.fetch("item_count"),
        productIds: properties.fetch("product_ids"),
        productNames: properties.fetch("product_names")
      }
    end

    def record_mapping_error(error)
      delivery.channel_user_mapping&.update!(last_error: error.message)
    end
  end
end
