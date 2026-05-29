class AccountController < ApplicationController
  def show
    @recent_product_views = current_user.product_views.includes(:product).order(viewed_at: :desc).limit(4)
    @cart_items = current_user.cart_items.includes(:product).order(created_at: :desc)
    @orders = current_user.orders.includes(order_items: :product).order(placed_at: :desc).limit(3)
  end
end
