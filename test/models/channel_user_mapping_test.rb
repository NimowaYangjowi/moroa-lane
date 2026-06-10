require "test_helper"

class ChannelUserMappingTest < ActiveSupport::TestCase
  test "requires a member id" do
    mapping = ChannelUserMapping.new(user: users(:one), channel_user_id: "channel-user-1")

    assert_not mapping.valid?
    assert_includes mapping.errors[:member_id], "can't be blank"
  end

  test "allows pending mappings before channel user id is known" do
    mapping = ChannelUserMapping.new(user: users(:one), member_id: users(:one).member_id)

    assert mapping.valid?
  end
end
