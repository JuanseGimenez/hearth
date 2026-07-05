require "test_helper"

class TuyaClientTest < ActiveSupport::TestCase
  def device
    Device.new(name: "L", tuya_device_id: "dev1", ip: "1.2.3.4",
               local_key: "k", protocol_version: "3.3", category: "light")
  end

  def client
    TuyaClient.new(device,
      python: "python3",
      bridge_path: Rails.root.join("test/support/fake_bridge.py").to_s)
  end

  test "turn_on sends the right command and returns ok" do
    result = client.turn_on
    assert result[:ok]
    echo = result[:state]["echo"]
    assert_equal "turn_on", echo["action"]
    assert_equal "dev1", echo["device_id"]
    assert_equal "3.3", echo["version"].to_s
  end

  test "set_brightness passes percent param" do
    result = client.set_brightness(40)
    assert_equal "set_brightness", result[:state]["echo"]["action"]
    assert_equal 40, result[:state]["echo"]["params"]["percent"]
  end

  test "set_color passes rgb params" do
    result = client.set_color(r: 10, g: 20, b: 30)
    params = result[:state]["echo"]["params"]
    assert_equal([10, 20, 30], [params["r"], params["g"], params["b"]])
  end

  test "returns error hash when bridge is missing" do
    bad = TuyaClient.new(device, python: "python3", bridge_path: "/no/such.py")
    result = bad.status
    assert_not result[:ok]
    assert result[:error].present?
  end
end
