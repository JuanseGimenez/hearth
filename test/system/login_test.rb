require "application_system_test_case"

class LoginTest < ApplicationSystemTestCase
  setup { ENV["SMART_HOME_PASSWORD"] = "secret" }

  test "the login page shows the Hearth brand" do
    visit login_path
    assert_text "Hearth"
    assert_selector "input[type=password]"
  end

  test "logging in reaches the devices dashboard" do
    visit root_path
    fill_in "password", with: "secret"
    click_on "Enter"
    assert_text "Devices"
  end
end
