class ChannelIdentityDemoSnapshot
  def self.build(user:)
    new(user:).build
  end

  def initialize(user:)
    @user = user
  end

  def build
    {
      generatedAt: Time.current.iso8601,
      identity: identity,
      metrics: metrics,
      flow: flow,
      requests: requests,
      payload: s2s_payload,
      records: records
    }
  end

  private

  attr_reader :user

  def identity
    {
      acmeUserId: user.id,
      uuid: user.uuid,
      memberId: user.member_id,
      channelUserId: mapping&.channel_user_id,
      mappingStatus: mapping_status,
      deliveryStatus: latest_delivery&.status || "none"
    }
  end

  def metrics
    {
      purchaseEvents: purchase_events_scope.count,
      orders: user.orders.count,
      deliveries: user.channel_event_deliveries.count
    }
  end

  def flow
    [
      { key: "acme_user", label: "Acme user", value: "users.id #{user.id}" },
      { key: "member_id", label: "memberId", value: user.member_id },
      { key: "user_api", label: "User API", value: "GET /users/@{memberId}" },
      { key: "mapping", label: "Mapping DB", value: mapping&.channel_user_id || "not synced" },
      { key: "s2s_event", label: "S2S Purchase", value: latest_event ? "event #{latest_event.id}" : "no purchase" },
      { key: "delivery", label: "Delivery", value: latest_delivery&.status || "none" }
    ]
  end

  def requests
    {
      userLookup: {
        method: "GET",
        path: "/open/v5/users/@#{user.member_id}",
        keyUsed: "memberId",
        responseKey: "user.id"
      },
      eventCreate: {
        method: "POST",
        path: "/open/v5/users/#{mapping&.channel_user_id || "{userId}"}/events",
        keyUsed: "userId",
        bodySource: "events.properties"
      },
      serverCredentials: {
        accessKey: ENV["CHANNELTALK_ACCESS_KEY"].present? ? "configured" : "missing",
        accessSecret: ENV["CHANNELTALK_ACCESS_SECRET"].present? ? "configured" : "missing"
      }
    }
  end

  def s2s_payload
    return nil unless latest_event

    properties = latest_event.properties
    {
      name: "Purchase",
      property: {
        orderId: properties.fetch("order_id").to_s,
        totalCents: properties.fetch("total_cents"),
        currency: properties.fetch("currency"),
        itemCount: properties.fetch("item_count"),
        productIds: properties.fetch("product_ids"),
        productNames: properties.fetch("product_names")
      }
    }
  end

  def records
    {
      users: record_for(user, %i[id uuid name email_address created_at]),
      orders: record_for(latest_order, %i[id user_id status total_cents placed_at created_at]),
      events: record_for(latest_event, %i[id name user_id subject_type subject_id properties occurred_at]),
      channel_user_mappings: record_for(mapping, %i[id user_id member_id channel_user_id synced_at last_error updated_at]),
      channel_event_deliveries: record_for(latest_delivery, %i[id event_id user_id member_id channel_user_id status attempts channel_event_id last_error sent_at updated_at])
    }
  end

  def record_for(record, fields)
    return nil unless record

    fields.to_h { |field| [ field, format_value(record.public_send(field)) ] }
  end

  def format_value(value)
    case value
    when Time, ActiveSupport::TimeWithZone
      value.iso8601
    else
      value
    end
  end

  def mapping_status
    return "not_created" unless mapping
    return "synced" if mapping.channel_user_id.present?

    "waiting_for_user_api"
  end

  def mapping
    @mapping ||= user.channel_user_mapping
  end

  def latest_order
    @latest_order ||= user.orders.order(created_at: :desc).first
  end

  def latest_event
    @latest_event ||= purchase_events_scope.order(created_at: :desc).first
  end

  def latest_delivery
    @latest_delivery ||= user.channel_event_deliveries.order(created_at: :desc).first
  end

  def purchase_events_scope
    user.events.where(name: "purchase")
  end
end
