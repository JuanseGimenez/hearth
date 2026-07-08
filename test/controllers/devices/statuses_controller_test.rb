require "test_helper"

class Devices::StatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["SMART_HOME_PASSWORD"] = "secret"
    post login_path, params: { password: "secret" }
    @device = Device.create!(name: "Lamp", tuya_device_id: "d1", ip: "1.2.3.4",
      local_key: "k", protocol_version: "3.3", category: "light",
      on_off: true, brightness: true, color: true)
  end

  test "show reports on for a light powered on (dp 20)" do
    fake = Minitest::Mock.new
    fake.expect(:status, { ok: true, state: { "20" => true } })
    TuyaClient.stub(:new, fake) do
      get device_status_path(@device)
    end
    assert_response :success
    assert_select ".status-on"
  end

  test "show reports off for a light powered off (dp 20)" do
    fake = Minitest::Mock.new
    fake.expect(:status, { ok: true, state: { "20" => false } })
    TuyaClient.stub(:new, fake) do
      get device_status_path(@device)
    end
    assert_select ".status-off"
  end

  test "show reports on for a plug on dp 1" do
    plug = Device.create!(name: "Plug", tuya_device_id: "p1", ip: "1.2.3.5",
      local_key: "k", protocol_version: "3.3", category: "plug", on_off: true)
    fake = Minitest::Mock.new
    fake.expect(:status, { ok: true, state: { "1" => true } })
    TuyaClient.stub(:new, fake) do
      get device_status_path(plug)
    end
    assert_select ".status-on"
  end

  test "show reports unreachable without an ip and does not call TuyaClient" do
    @device.update!(ip: "")
    TuyaClient.stub(:new, ->(*) { raise "TuyaClient should not be called without an ip" }) do
      get device_status_path(@device)
    end
    assert_response :success
    assert_select ".status-unreachable"
  end
end
