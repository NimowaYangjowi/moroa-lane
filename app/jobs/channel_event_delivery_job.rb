class ChannelEventDeliveryJob < ApplicationJob
  queue_as :default

  def perform(delivery)
    return unless delivery.start_processing!

    ChannelTalk::PurchaseEventDelivery.new(delivery:).call
  rescue StandardError => error
    delivery.mark_failed!(error.message)
  end
end
