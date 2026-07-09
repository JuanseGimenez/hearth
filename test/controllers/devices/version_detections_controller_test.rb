require "test_helper"

class Devices::VersionDetectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["SMART_HOME_PASSWORD"] = "secret"
    post login_path, params: { password: "secret" }
    @device = Device.create!(name: "Lamp", tuya_device_id: "d1", ip: "1.2.3.4",
      local_key: "k", protocol_version: "3.3", category: "light",
      on_off: true, brightness: true, color: true)
  end

  test "create finds and persists the first working protocol version" do
    results = [ { ok: false, error: "x" }, { ok: false, error: "x" }, { ok: true, state: {} } ]
    fake = Object.new
    fake.define_singleton_method(:status) { results.shift }
    TuyaClient.stub(:new, fake) do
      post device_version_detection_path(@device)
    end
    assert_redirected_to edit_device_path(@device)
    assert_equal "3.5", @device.reload.protocol_version
  end

  test "create without an ip warns and does not call TuyaClient" do
    @device.update!(ip: "")
    TuyaClient.stub(:new, ->(*) { raise "TuyaClient should not be called without an ip" }) do
      post device_version_detection_path(@device)
    end
    assert_redirected_to edit_device_path(@device)
    assert flash[:alert].present?
  end
end
