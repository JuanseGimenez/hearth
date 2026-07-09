require "test_helper"

class Devices::StatusFetcherTest < ActiveSupport::TestCase
  def device(ip: "1.2.3.4")
    Device.new(name: "L", tuya_device_id: "d1", ip: ip,
      local_key: "k", protocol_version: "3.3", category: "light")
  end

  test "returns an unreachable result without an ip and never builds the client" do
    TuyaClient.stub(:new, ->(*) { raise "client should not be built" }) do
      assert_equal({ ok: false, error: "no ip" }, Devices::StatusFetcher.new(device(ip: "")).call)
    end
  end

  test "delegates to the client status when an ip is present" do
    fake = Minitest::Mock.new
    fake.expect(:status, { ok: true, state: { "20" => true } })
    result = TuyaClient.stub(:new, fake) { Devices::StatusFetcher.new(device).call }
    assert fake.verify
    assert result[:ok]
  end
end
