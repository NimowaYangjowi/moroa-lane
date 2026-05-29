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
    cookies[:channel_member_logged_out] = "1"

    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
    assert_empty cookies[:channel_member_logged_out]
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
    assert_equal "1", cookies[:channel_member_logged_out]
    assert_equal true, flash[:channel_logged_out]
  end

  test "logout button shuts down ChannelTalk member session" do
    sign_in_as(User.take)

    previous_plugin_key = ENV["CHANNELTALK_PLUGIN_KEY"]
    ENV["CHANNELTALK_PLUGIN_KEY"] = "plugin-key"

    get root_path

    assert_response :success
    assert_select "form[data-channel-logout-form]"
    assert_includes response.body, 'ChannelIO("shutdown")'
    assert_includes response.body, "clearChannelTalkBrowserState"
  ensure
    ENV["CHANNELTALK_PLUGIN_KEY"] = previous_plugin_key
  end

  test "redirect after logout clears ChannelTalk state without rebooting sdk" do
    sign_in_as(User.take)

    previous_plugin_key = ENV["CHANNELTALK_PLUGIN_KEY"]
    ENV["CHANNELTALK_PLUGIN_KEY"] = "plugin-key"

    delete session_path
    follow_redirect!

    assert_response :success
    assert_includes response.body, "_channeltalk_session=; Max-Age=0"
    assert_no_match(/ChannelIO\("boot"/, response.body)
    assert_no_match(/shop_user_/, response.body)
  ensure
    ENV["CHANNELTALK_PLUGIN_KEY"] = previous_plugin_key
  end

  test "logged out browser does not boot ChannelTalk on guest pages" do
    previous_plugin_key = ENV["CHANNELTALK_PLUGIN_KEY"]
    ENV["CHANNELTALK_PLUGIN_KEY"] = "plugin-key"
    cookies[:channel_member_logged_out] = "1"

    get products_path

    assert_response :success
    assert_includes response.body, "_channeltalk_session=; Max-Age=0"
    assert_no_match(/ChannelIO\("boot"/, response.body)
    assert_no_match(/shop_user_/, response.body)
  ensure
    ENV["CHANNELTALK_PLUGIN_KEY"] = previous_plugin_key
  end
end
