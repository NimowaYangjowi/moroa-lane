require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
    assert_select "input[name=login_email][type=text][value='jiwoo@example.com']"
    assert_select "input[name=login_password][value='password123']"
    assert_select ".demo-credentials", false
    assert_select "form[data-turbo=false]"
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "logout button shuts down ChannelTalk member session" do
    sign_in_as(User.take)

    previous_plugin_key = ENV["CHANNELTALK_PLUGIN_KEY"]
    ENV["CHANNELTALK_PLUGIN_KEY"] = "plugin-key"

    get root_path

    assert_response :success
    assert_select "form[data-channel-logout-form]"
    assert_includes response.body, 'ChannelIO("shutdown")'
  ensure
    ENV["CHANNELTALK_PLUGIN_KEY"] = previous_plugin_key
  end
end
