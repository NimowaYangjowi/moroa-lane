class OrdersController < ApplicationController
  def create
    cart_items = current_user.cart_items.includes(:product).order(:created_at).to_a

    if cart_items.empty?
      redirect_to cart_path, alert: "Add a product before placing an order."
      return
    end

    order = nil
    ActiveRecord::Base.transaction do
      order = create_order_from_cart(cart_items)
      event = record_purchase_event(order)
      ChannelEventDelivery.create!(
        event:,
        user: current_user,
        member_id: current_user.member_id
      )
      cart_items.each(&:destroy!)
    end

    redirect_to account_path, notice: "Order placed. Your routine is saved to your order history."
  end

  private

  def create_order_from_cart(cart_items)
    order = current_user.orders.create!(
      status: "paid",
      total_cents: cart_items.sum(&:line_total_cents),
      placed_at: Time.current
    )

    cart_items.each do |cart_item|
      order.order_items.create!(
        product: cart_item.product,
        quantity: cart_item.quantity,
        price_cents: cart_item.product.price_cents
      )
    end

    order
  end

  def record_purchase_event(order)
    order_items = order.order_items.includes(:product).to_a

    record_event(
      "purchase",
      subject: order,
      properties: {
        order_id: order.id,
        total_cents: order.total_cents,
        currency: "USD",
        item_count: order_items.sum(&:quantity),
        product_ids: order_items.map(&:product_id),
        product_names: order_items.map { |item| item.product.name }
      }
    )
  end
end
