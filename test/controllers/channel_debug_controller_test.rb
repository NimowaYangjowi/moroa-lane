require "test_helper"

class ChannelDebugControllerTest < ActionDispatch::IntegrationTest
  test "should show anonymous payload" do
    with_channel_env(plugin_key: nil, member_hash_secret: nil) do
      get channel_debug_url

      assert_response :success
      assert_select "h1", "ChannelTalk payload"
      assert_select "h2", "Local fallback"
      assert_select "h2", "Anonymous payload"
      assert_select "code", text: /"pluginKey": "YOUR_PLUGIN_KEY"/
      assert_no_match(/"memberId"/, css_select("code").first.text)
    end
  end

  test "should show member payload" do
    user = users(:one)

    with_channel_env(plugin_key: "plugin-key", member_hash_secret: "secret") do
      sign_in_as user
      get channel_debug_url

      assert_response :success
      assert_select "h2", "Live SDK boot"
      assert_select "h2", "Member payload"
      assert_select "dd", user.member_id
      assert_select "dd", "Present"
      assert_select "code", text: /"memberId": "#{user.member_id}"/
      assert_select "code", text: /"email": "#{user.email_address}"/
      assert_select "code", text: /"customerTier": "#{user.customer_tier}"/
      assert_select "strong", "tier-#{user.customer_tier.parameterize}"
      assert_select "strong", "skin-#{user.skin_type.parameterize}"
      assert_select "code", text: /"memberHash":/
    end
  end

  private

  def with_channel_env(plugin_key:, member_hash_secret:)
    previous_plugin_key = ENV["CHANNELTALK_PLUGIN_KEY"]
    previous_member_hash_secret = ENV["CHANNELTALK_MEMBER_HASH_SECRET"]

    ENV["CHANNELTALK_PLUGIN_KEY"] = plugin_key
    ENV["CHANNELTALK_MEMBER_HASH_SECRET"] = member_hash_secret

    yield
  ensure
    ENV["CHANNELTALK_PLUGIN_KEY"] = previous_plugin_key
    ENV["CHANNELTALK_MEMBER_HASH_SECRET"] = previous_member_hash_secret
  end
end
