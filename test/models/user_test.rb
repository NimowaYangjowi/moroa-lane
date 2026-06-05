require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(name: "Jiwoo Han", email_address: " DOWNCASED@EXAMPLE.COM ", password: "password123")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "member_id uses stable uuid" do
    assert_equal "shop_user_#{users(:one).uuid}", users(:one).member_id
  end

  test "assigns uuid on create" do
    user = User.create!(
      name: "Jiwoo Han",
      email_address: "new@example.com",
      password: "password123",
      password_confirmation: "password123",
      customer_tier: "New",
      skin_type: "Dry skin"
    )

    assert user.uuid.present?
  end
end
