require "test_helper"

class Devices::CommandRunnerTest < ActiveSupport::TestCase
  def device
    Device.new(name: "L", tuya_device_id: "d1", ip: "1.2.3.4",
      local_key: "k", protocol_version: "3.3", category: "light")
  end

  test "turn_on dispatches to the client and returns its result" do
    fake = Minitest::Mock.new
    fake.expect(:turn_on, { ok: true, state: {} })
    result = TuyaClient.stub(:new, fake) do
      Devices::CommandRunner.new(device).call("turn_on")
    end
    assert fake.verify
    assert result[:ok]
  end

  test "set_brightness forwards the percent param" do
    fake = Minitest::Mock.new
    fake.expect(:set_brightness, { ok: true }, [ "40" ])
    TuyaClient.stub(:new, fake) do
      Devices::CommandRunner.new(device).call("set_brightness", percent: "40")
    end
    assert fake.verify
  end

  test "set_color forwards the rgb params" do
    fake = Minitest::Mock.new
    fake.expect(:set_color, { ok: true }, r: "1", g: "2", b: "3")
    TuyaClient.stub(:new, fake) do
      Devices::CommandRunner.new(device).call("set_color", r: "1", g: "2", b: "3")
    end
    assert fake.verify
  end

  test "an unknown action is rejected without touching the client" do
    TuyaClient.stub(:new, ->(*) { raise "client should not be built" }) do
      result = Devices::CommandRunner.new(device).call("explode")
      assert_equal({ ok: false, invalid: true }, result)
    end
  end
end
