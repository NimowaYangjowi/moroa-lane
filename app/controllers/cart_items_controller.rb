class CartItemsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    cart_item = current_user.cart_items.find_or_initialize_by(product:)
    existing_item = cart_item.persisted?
    cart_item.quantity = quantity_param
    cart_item.save!

    message = existing_item ? "#{product.name} was updated in your cart." : "#{product.name} was added to your cart."
    redirect_to cart_path, notice: message
  end

  def update
    cart_item = current_user.cart_items.find(params[:id])
    cart_item.update!(quantity: quantity_param)

    redirect_to cart_path, notice: "Cart updated."
  end

  def destroy
    cart_item = current_user.cart_items.find(params[:id])
    cart_item.destroy!

    redirect_to cart_path, notice: "Item removed from cart."
  end

  private

  def quantity_param
    params.fetch(:quantity, 1).to_i.clamp(1, 9)
  end
end
