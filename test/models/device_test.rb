require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  def valid_attrs
    {
      name: "Living lamp", tuya_device_id: "abc123", ip: "192.168.0.50",
      local_key: "key123", protocol_version: "3.3", category: "light",
      on_off: true, brightness: true, color: true
    }
  end

  test "valid device saves" do
    assert Device.new(valid_attrs).valid?
  end

  test "requires name, tuya_device_id, local_key, protocol_version" do
    device = Device.new
    assert_not device.valid?
    assert device.errors.of_kind?(:name, :blank)
    assert device.errors.of_kind?(:tuya_device_id, :blank)
    assert device.errors.of_kind?(:local_key, :blank)
    assert device.errors.of_kind?(:protocol_version, :blank)
  end

  test "category must be plug or light" do
    assert_not Device.new(valid_attrs.merge(category: "toaster")).valid?
    assert Device.new(valid_attrs.merge(category: "plug")).valid?
  end

  test "supports? reflects capability flags" do
    device = Device.new(valid_attrs.merge(brightness: false))
    assert device.supports?(:color)
    assert_not device.supports?(:brightness)
  end
end
