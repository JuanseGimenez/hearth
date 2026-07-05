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

  test "edit renders the form" do
    get edit_device_path(@device)
    assert_response :success
  end

  test "update changes device attributes and redirects" do
    patch device_path(@device), params: {
      device: { name: "Renamed", protocol_version: "3.5", category: "plug", brightness: false }
    }
    assert_redirected_to root_path
    @device.reload
    assert_equal "Renamed", @device.name
    assert_equal "3.5", @device.protocol_version
    assert_equal "plug", @device.category
    assert_not @device.brightness
  end

  test "destroy removes the device" do
    assert_difference -> { Device.count }, -1 do
      delete device_path(@device)
    end
    assert_redirected_to root_path
  end

  test "detect_version finds and persists the first working protocol version" do
    @device.update!(ip: "1.2.3.4", protocol_version: "3.3")
    # 3.3 fails, 3.4 fails, 3.5 works — matches DevicesController::PROTOCOL_VERSIONS order
    results = [ { ok: false, error: "x" }, { ok: false, error: "x" }, { ok: true, state: {} } ]
    fake = Object.new
    fake.define_singleton_method(:status) { results.shift }
    TuyaClient.stub(:new, fake) do
      post detect_version_device_path(@device)
    end
    assert_redirected_to edit_device_path(@device)
    assert_equal "3.5", @device.reload.protocol_version
  end

  test "detect_version without an ip warns and does not call TuyaClient" do
    @device.update!(ip: "")
    TuyaClient.stub(:new, ->(*) { raise "TuyaClient should not be called without an ip" }) do
      post detect_version_device_path(@device)
    end
    assert_redirected_to edit_device_path(@device)
    assert flash[:alert].present?
  end
end
