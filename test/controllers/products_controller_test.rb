require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get show" do
    assert_difference("Event.where(name: 'content_view').count", 1) do
      get product_url(products(:one))
    end

    assert_response :success

    event = Event.order(:created_at).last
    assert_equal "content_view", event.name
    assert_nil event.user
    assert_equal products(:one), event.subject
    assert_equal products(:one).slug, event.properties.fetch("product_slug")
  end
end
