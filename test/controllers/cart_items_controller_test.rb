require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "should create cart item with requested quantity" do
    CartItem.where(user: users(:one), product: products(:two)).delete_all

    assert_difference("CartItem.count", 1) do
      assert_difference("Event.where(name: 'add_to_cart').count", 1) do
        post cart_items_url, params: { product_id: products(:two).id, quantity: 2 }
      end
    end

    assert_redirected_to cart_path
    assert_equal 2, users(:one).cart_items.find_by!(product: products(:two)).quantity

    event = Event.order(:created_at).last
    assert_equal "add_to_cart", event.name
    assert_equal users(:one), event.user
    assert_equal products(:two), event.subject
    assert_equal 2, event.properties.fetch("quantity")
    assert_equal false, event.properties.fetch("existing_cart_item")
  end

  test "should set existing cart item to requested quantity" do
    assert_no_difference("CartItem.count") do
      assert_difference("Event.where(name: 'add_to_cart').count", 1) do
        post cart_items_url, params: { product_id: products(:one).id, quantity: 2 }
      end
    end

    assert_redirected_to cart_path
    assert_equal "Cloud Barrier Cream was updated in your cart.", flash[:notice]
    assert_equal 2, cart_items(:one).reload.quantity

    event = Event.order(:created_at).last
    assert_equal true, event.properties.fetch("existing_cart_item")
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
