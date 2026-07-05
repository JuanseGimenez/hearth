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
end
