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
end
