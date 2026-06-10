require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count", 1) do
      assert_difference("Event.where(name: 'registration').count", 1) do
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
    end

    event = Event.order(:created_at).last
    assert_equal "registration", event.name
    assert_equal User.find_by!(email_address: "jiwoo@example.com"), event.user
    assert event.properties.fetch("session_id")

    assert_redirected_to account_path
  end

  test "does not record registration event when validation fails" do
    assert_no_difference("Event.count") do
      post registration_url, params: {
        user: {
          name: "Jiwoo Han",
          email_address: users(:one).email_address,
          skin_type: "Combination skin",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
