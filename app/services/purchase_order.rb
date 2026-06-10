class PurchaseOrder
  Result = Data.define(:order, :event, :delivery)

  def self.call(user:, cart_items:, enqueue_delivery: true)
    new(user:, cart_items:, enqueue_delivery:).call
  end

  def initialize(user:, cart_items:, enqueue_delivery:)
    @user = user
    @cart_items = cart_items
    @enqueue_delivery = enqueue_delivery
  end

  def call
    raise ArgumentError, "cart_items must be present" if cart_items.empty?

    result = nil
    ActiveRecord::Base.transaction do
      order = create_order
      event = create_purchase_event(order)
      delivery = create_delivery(event)
      cart_items.each(&:destroy!)
      result = Result.new(order:, event:, delivery:)
    end

    ChannelEventDeliveryJob.perform_later(result.delivery) if enqueue_delivery
    result
  end

  private

  attr_reader :user, :cart_items, :enqueue_delivery

  def create_order
    order = user.orders.create!(
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

  def create_purchase_event(order)
    order_items = order.order_items.includes(:product).to_a

    Event.create!(
      name: "purchase",
      user:,
      subject: order,
      properties: {
        order_id: order.id,
        total_cents: order.total_cents,
        currency: "USD",
        item_count: order_items.sum(&:quantity),
        product_ids: order_items.map(&:product_id),
        product_names: order_items.map { |item| item.product.name }
      },
      occurred_at: Time.current
    )
  end

  def create_delivery(event)
    ChannelEventDelivery.create!(
      event:,
      user:,
      member_id: user.member_id
    )
  end
end
