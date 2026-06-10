class ChannelIdentityDemoController < ApplicationController
  def show
  end

  def status
    render json: ChannelIdentityDemoSnapshot.build(user: current_user)
  end

  def create_purchase
    ensure_demo_cart_item
    cart_items = current_user.cart_items.includes(:product).order(:created_at).to_a
    PurchaseOrder.call(user: current_user, cart_items:, enqueue_delivery: false)

    render json: ChannelIdentityDemoSnapshot.build(user: current_user), status: :created
  end

  def run_delivery
    delivery = current_user.channel_event_deliveries.order(created_at: :desc).first

    if delivery
      delivery.update!(status: "pending") if delivery.status == "failed" && delivery.attempts < ChannelEventDelivery::MAX_ATTEMPTS
      ChannelEventDeliveryJob.perform_now(delivery)
    end

    render json: ChannelIdentityDemoSnapshot.build(user: current_user)
  end

  private

  def ensure_demo_cart_item
    return if current_user.cart_items.exists?

    product = Product.featured.order(:id).first || Product.order(:id).first
    current_user.cart_items.create!(product:, quantity: 1)
  end
end
