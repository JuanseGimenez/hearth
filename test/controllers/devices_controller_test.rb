require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["SMART_HOME_PASSWORD"] = "secret"
    post login_path, params: { password: "secret" }
    @device = Device.create!(name: "Lamp", tuya_device_id: "d1", ip: "1.2.3.4",
      local_key: "k", protocol_version: "3.3", category: "light",
      on_off: true, brightness: true, color: true)
  end

  test "index lists devices" do
    get root_path
    assert_response :success
    assert_select "*", text: /Lamp/
  end

  test "command calls TuyaClient and redirects back" do
    fake = Minitest::Mock.new
    fake.expect(:turn_on, { ok: true, state: {} })
    TuyaClient.stub(:new, fake) do
      post command_device_path(@device), params: { action_name: "turn_on" }
    end
    assert fake.verify
    assert_response :redirect
  end
end
