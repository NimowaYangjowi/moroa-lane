class ChannelUserMapping < ApplicationRecord
  belongs_to :user
  has_many :channel_event_deliveries, dependent: :nullify

  validates :member_id, presence: true, uniqueness: true
  validates :channel_user_id, uniqueness: true, allow_blank: true
end
