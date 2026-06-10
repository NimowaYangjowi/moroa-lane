class ChannelEventDelivery < ApplicationRecord
  STATUSES = %w[pending processing sent failed].freeze
  MAX_ATTEMPTS = 3

  belongs_to :event
  belongs_to :user
  belongs_to :channel_user_mapping, optional: true

  validates :member_id, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :event_id, uniqueness: true

  def start_processing!
    with_lock do
      return false unless status == "pending"
      if attempts >= MAX_ATTEMPTS
        update!(status: "failed", last_error: "Maximum ChannelTalk delivery attempts reached")
        return false
      end

      update!(status: "processing", attempts: attempts + 1, last_error: nil)
    end
  end

  def mark_sent!(channel_user_mapping:, channel_user_id:, channel_event_id:)
    update!(
      channel_user_mapping:,
      channel_user_id:,
      channel_event_id:,
      status: "sent",
      sent_at: Time.current,
      last_error: nil
    )
  end

  def mark_failed!(message)
    update!(status: "failed", last_error: message)
  end
end
