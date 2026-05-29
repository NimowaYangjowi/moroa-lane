require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(name: "Downcase", email_address: " DOWNCASED@EXAMPLE.COM ", password: "password123")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "member_id uses stable database id" do
    assert_equal "user_#{users(:one).id}", users(:one).member_id
  end
end
