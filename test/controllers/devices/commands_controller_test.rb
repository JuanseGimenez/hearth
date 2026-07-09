require "test_helper"

class Devices::CommandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["SMART_HOME_PASSWORD"] = "secret"
    post login_path, params: { password: "secret" }
    @device = Device.create!(name: "Lamp", tuya_device_id: "d1", ip: "1.2.3.4",
      local_key: "k", protocol_version: "3.3", category: "light",
      on_off: true, brightness: true, color: true)
  end

  test "create runs the command and redirects back" do
    fake = Minitest::Mock.new
    fake.expect(:turn_on, { ok: true, state: {} })
    TuyaClient.stub(:new, fake) do
      post device_commands_path(@device), params: { action_name: "turn_on" }
    end
    assert fake.verify
    assert_redirected_to root_path
  end

  test "create rejects an unknown action with bad request" do
    TuyaClient.stub(:new, ->(*) { raise "client should not be built" }) do
      post device_commands_path(@device), params: { action_name: "explode" }
    end
    assert_response :bad_request
  end
end
