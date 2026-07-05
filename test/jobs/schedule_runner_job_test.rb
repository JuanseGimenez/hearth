require "test_helper"

class ScheduleRunnerJobTest < ActiveJob::TestCase
  setup do
    @device = Device.create!(name: "L", tuya_device_id: "d", ip: "1.1.1.1",
      local_key: "k", protocol_version: "3.3", category: "plug", on_off: true)
  end

  test "runs due schedules through TuyaClient" do
    Schedule.create!(device: @device, action: "turn_on", hour: 7, minute: 0, enabled: true)
    time = Time.zone.local(2026, 7, 6, 7, 0)

    fake = Minitest::Mock.new
    fake.expect(:turn_on, { ok: true, state: {} })
    TuyaClient.stub(:new, fake) do
      ScheduleRunnerJob.perform_now(time)
    end
    assert fake.verify
  end

  test "runs a set_color schedule with rgb params" do
    Schedule.create!(device: @device, action: "set_color", hour: 7, minute: 0,
                     enabled: true, params: { "r" => 10, "g" => 20, "b" => 30 })
    time = Time.zone.local(2026, 7, 6, 7, 0)

    fake = Minitest::Mock.new
    fake.expect(:set_color, { ok: true, state: {} }, [], r: 10, g: 20, b: 30)
    TuyaClient.stub(:new, fake) do
      ScheduleRunnerJob.perform_now(time)
    end
    assert fake.verify
  end

  test "one failing schedule does not abort the rest of the batch" do
    bad  = Schedule.create!(device: @device, action: "set_color", hour: 7, minute: 0, enabled: true, params: {})
    good = Schedule.create!(device: @device, action: "turn_on",  hour: 7, minute: 0, enabled: true)
    time = Time.zone.local(2026, 7, 6, 7, 0)

    calls = []
    stub_client = Object.new
    stub_client.define_singleton_method(:set_color) { |**| raise ArgumentError, "missing keywords" }
    stub_client.define_singleton_method(:turn_on)  { calls << :turn_on; { ok: true, state: {} } }

    TuyaClient.stub(:new, stub_client) do
      assert_nothing_raised { ScheduleRunnerJob.perform_now(time) }
    end
    assert_includes calls, :turn_on
  end
end
