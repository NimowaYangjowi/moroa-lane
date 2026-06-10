class ChannelEventDelivery < ApplicationRecord
  STATUSES = %w[pending processing sent failed].freeze

  belongs_to :event
  belongs_to :user
  belongs_to :channel_user_mapping, optional: true

  validates :member_id, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :event_id, uniqueness: true
end
