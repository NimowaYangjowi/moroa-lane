require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: {
          name: "Jiwoo Han",
          email_address: "jiwoo@example.com",
          skin_type: "Combination skin",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to account_path
  end
end
