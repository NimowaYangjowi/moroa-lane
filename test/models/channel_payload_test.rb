require "test_helper"

class ChannelPayloadTest < ActiveSupport::TestCase
  test "builds anonymous payload without member id" do
    payload = ChannelPayload.build(user: nil, plugin_key: "plugin-key")

    assert_equal "plugin-key", payload[:pluginKey]
    assert_nil payload[:memberId]
  end

  test "builds member payload with profile" do
    user = users(:one)
    payload = ChannelPayload.build(user:, plugin_key: "plugin-key")

    assert_equal user.member_id, payload[:memberId]
    assert_equal user.name, payload[:profile][:name]
    assert_equal user.email_address, payload[:profile][:email]
    assert_equal user.uuid, payload[:profile][:externalUserId]
    assert_equal user.customer_tier, payload[:profile][:customerTier]
    assert_equal user.skin_type, payload[:profile][:skinType]
    assert_includes payload[:tags], "tier-#{user.customer_tier.parameterize}"
    assert_includes payload[:tags], "skin-#{user.skin_type.parameterize}"
  end

  test "adds member hash when secret is present" do
    user = users(:one)
    payload = ChannelPayload.build(user:, plugin_key: "plugin-key", member_hash_secret: "secret")

    assert payload[:memberHash].present?
    assert_equal OpenSSL::HMAC.hexdigest("SHA256", "secret", user.member_id), payload[:memberHash]
  end
end
