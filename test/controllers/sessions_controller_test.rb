require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { ENV["SMART_HOME_PASSWORD"] = "secret" }

  test "protected page redirects to login when not authenticated" do
    get root_path
    assert_redirected_to login_path
  end

  test "wrong password does not authenticate" do
    post login_path, params: { password: "nope" }
    assert_response :unprocessable_entity
  end

  test "correct password authenticates and reaches root" do
    post login_path, params: { password: "secret" }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "blank password is rejected when SMART_HOME_PASSWORD is unset" do
    ENV.delete("SMART_HOME_PASSWORD")
    post login_path, params: { password: "" }
    assert_response :unprocessable_entity
    get root_path
    assert_redirected_to login_path
  ensure
    ENV["SMART_HOME_PASSWORD"] = "secret"
  end

  test "blank password is rejected even when a real password is set" do
    post login_path, params: { password: "" }
    assert_response :unprocessable_entity
  end
end
