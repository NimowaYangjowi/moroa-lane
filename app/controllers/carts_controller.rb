class CartsController < ApplicationController
  def show
    @cart_items = current_user.cart_items.includes(:product).order(created_at: :desc)
    @cart_total_cents = current_user.cart_total_cents
  end
end
