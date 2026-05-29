require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "should create cart item" do
    CartItem.where(user: users(:one), product: products(:two)).delete_all

    assert_difference("CartItem.count", 1) do
      post cart_items_url, params: { product_id: products(:two).id, quantity: 2 }
    end

    assert_redirected_to cart_path
  end

  test "should update cart item" do
    patch cart_item_url(cart_items(:one)), params: { quantity: 3 }

    assert_redirected_to cart_path
    assert_equal 3, cart_items(:one).reload.quantity
  end

  test "should destroy cart item" do
    assert_difference("CartItem.count", -1) do
      delete cart_item_url(cart_items(:one))
    end

    assert_redirected_to cart_path
  end
end
