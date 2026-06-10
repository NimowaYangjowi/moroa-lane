class OrdersController < ApplicationController
  def create
    cart_items = current_user.cart_items.includes(:product).order(:created_at).to_a

    if cart_items.empty?
      redirect_to cart_path, alert: "Add a product before placing an order."
      return
    end

    PurchaseOrder.call(user: current_user, cart_items:)

    redirect_to account_path, notice: "Order placed. Your routine is saved to your order history."
  end
end
