require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  setup do
    @device = Device.create!(name: "L", tuya_device_id: "d", ip: "1.1.1.1",
      local_key: "k", protocol_version: "3.3", category: "plug", on_off: true)
  end

  test "due returns enabled schedules matching hour and minute" do
    match = Schedule.create!(device: @device, action: "turn_on", hour: 19, minute: 30, enabled: true)
    Schedule.create!(device: @device, action: "turn_off", hour: 20, minute: 0, enabled: true)
    Schedule.create!(device: @device, action: "turn_on", hour: 19, minute: 30, enabled: false)

    time = Time.zone.local(2026, 7, 5, 19, 30) # a Sunday (wday 0)
    assert_equal [ match ], Schedule.due(time).to_a
  end

  test "days_of_week filters by weekday when present" do
    s = Schedule.create!(device: @device, action: "turn_on", hour: 8, minute: 0,
                         enabled: true, days_of_week: "1,2,3,4,5")
    weekday = Time.zone.local(2026, 7, 6, 8, 0)  # Monday (wday 1)
    weekend = Time.zone.local(2026, 7, 5, 8, 0)  # Sunday (wday 0)
    assert_includes Schedule.due(weekday).to_a, s
    assert_not_includes Schedule.due(weekend).to_a, s
  end
end
