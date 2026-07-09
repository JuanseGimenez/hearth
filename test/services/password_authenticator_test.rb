require "test_helper"

class PasswordAuthenticatorTest < ActiveSupport::TestCase
  test "accepts the configured password" do
    ENV["SMART_HOME_PASSWORD"] = "secret"
    assert PasswordAuthenticator.call("secret")
  end

  test "rejects a wrong password" do
    ENV["SMART_HOME_PASSWORD"] = "secret"
    assert_not PasswordAuthenticator.call("nope")
  end

  test "rejects everything when no password is configured" do
    ENV.delete("SMART_HOME_PASSWORD")
    assert_not PasswordAuthenticator.call("")
    assert_not PasswordAuthenticator.call("anything")
  ensure
    ENV["SMART_HOME_PASSWORD"] = "secret"
  end
end
