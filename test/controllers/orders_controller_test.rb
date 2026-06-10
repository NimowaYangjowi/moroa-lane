require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    sign_in_as users(:one)
  end

  test "creates an order and records a pending purchase delivery" do
    product = cart_items(:one).product
    expected_total = cart_items(:one).line_total_cents

    assert_difference("Order.count", 1) do
      assert_difference("OrderItem.count", 1) do
        assert_difference("Event.where(name: 'purchase').count", 1) do
          assert_difference("ChannelEventDelivery.count", 1) do
            assert_difference("users(:one).cart_items.count", -1) do
              assert_enqueued_with(job: ChannelEventDeliveryJob) do
                post orders_url
              end
            end
          end
        end
      end
    end

    assert_redirected_to account_path

    order = Order.order(:created_at).last
    assert_equal users(:one), order.user
    assert_equal "paid", order.status
    assert_equal expected_total, order.total_cents
    assert_equal product, order.order_items.first.product

    event = Event.where(name: "purchase").order(:created_at).last
    assert_equal users(:one), event.user
    assert_equal order, event.subject
    assert_equal order.id, event.properties.fetch("order_id")
    assert_equal expected_total, event.properties.fetch("total_cents")
    assert_equal "USD", event.properties.fetch("currency")
    assert_equal 1, event.properties.fetch("item_count")
    assert_equal [ product.id ], event.properties.fetch("product_ids")
    assert_equal [ product.name ], event.properties.fetch("product_names")

    delivery = event.channel_event_delivery
    assert_equal users(:one), delivery.user
    assert_equal users(:one).member_id, delivery.member_id
    assert_equal "pending", delivery.status
  end

  test "does not create purchase records for an empty cart" do
    users(:one).cart_items.destroy_all

    assert_no_difference("Order.count") do
      assert_no_difference("OrderItem.count") do
        assert_no_difference("Event.where(name: 'purchase').count") do
          assert_no_difference("ChannelEventDelivery.count") do
            post orders_url
          end
        end
      end
    end

    assert_redirected_to cart_path
    assert_equal "Add a product before placing an order.", flash[:alert]
  end
end
