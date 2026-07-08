require "test_helper"

class Devices::VersionDetectorTest < ActiveSupport::TestCase
  def device(ip: "1.2.3.4")
    Device.create!(name: "L", tuya_device_id: "d1", ip: ip,
      local_key: "k", protocol_version: "3.3", category: "light")
  end

  test "returns :no_ip and never reaches the client without an ip" do
    TuyaClient.stub(:new, ->(*) { raise "client should not be built" }) do
      assert_equal({ status: :no_ip }, Devices::VersionDetector.new(device(ip: "")).call)
    end
  end

  test "detects and persists the first working protocol version" do
    d = device
    results = [ { ok: false }, { ok: false }, { ok: true } ] # 3.3, 3.4 fail; 3.5 works
    fake = Object.new
    fake.define_singleton_method(:status) { results.shift }
    result = TuyaClient.stub(:new, fake) { Devices::VersionDetector.new(d).call }
    assert_equal({ status: :detected, version: "3.5" }, result)
    assert_equal "3.5", d.reload.protocol_version
  end

  test "returns :not_found when no version responds" do
    d = device
    fake = Object.new
    fake.define_singleton_method(:status) { { ok: false } }
    result = TuyaClient.stub(:new, fake) { Devices::VersionDetector.new(d).call }
    assert_equal({ status: :not_found }, result)
  end
end
