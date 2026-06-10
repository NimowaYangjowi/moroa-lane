class ApplicationController < ActionController::Base
  include Authentication
  helper_method :current_user, :channel_boot_options, :channel_event_payloads, :channel_sdk_enabled?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def current_user
    resume_session&.user
  end

  def channel_boot_options
    ChannelPayload.build(
      user: current_user,
      plugin_key: ENV["CHANNELTALK_PLUGIN_KEY"].presence || "YOUR_PLUGIN_KEY",
      member_hash_secret: ENV["CHANNELTALK_MEMBER_HASH_SECRET"].presence
    )
  end

  def channel_sdk_enabled?
    ENV["CHANNELTALK_PLUGIN_KEY"].present?
  end

  def record_event(name, user: current_user, subject: nil, properties:)
    Event.create!(
      name:,
      user:,
      subject:,
      properties:,
      occurred_at: Time.current
    ).tap { |event| queue_channel_event(event) }
  end

  def channel_event_payloads
    Array(flash[:channel_events]) + Array(@channel_events)
  end

  def queue_channel_event(event)
    return unless channel_sdk_enabled?

    payload = channel_event_payload(event)

    if request.get?
      @channel_events = Array(@channel_events) + [ payload ]
    else
      flash[:channel_events] = Array(flash[:channel_events]) + [ payload ]
    end
  end

  def channel_event_payload(event)
    {
      name: event.name,
      properties: channel_event_properties(event)
    }
  end

  def channel_event_properties(event)
    event.properties
      .deep_stringify_keys
      .except("session_id")
      .merge(
        "source" => "acme_corp_storefront",
        "occurred_at" => event.occurred_at.iso8601
      )
  end
end
