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

  test "queues content view event for ChannelTalk tracking" do
    previous_plugin_key = ENV["CHANNELTALK_PLUGIN_KEY"]
    ENV["CHANNELTALK_PLUGIN_KEY"] = "plugin-key"

    get product_url(products(:one))

    assert_response :success
    assert_includes response.body, "channelPendingEvents"
    assert_includes response.body, '"name":"content_view"'
    assert_includes response.body, products(:one).slug
  ensure
    ENV["CHANNELTALK_PLUGIN_KEY"] = previous_plugin_key
  end
end
