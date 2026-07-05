require "test_helper"

class SchedulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["SMART_HOME_PASSWORD"] = "secret"
    post login_path, params: { password: "secret" }
    @device = Device.create!(name: "L", tuya_device_id: "d", ip: "1.1.1.1",
      local_key: "k", protocol_version: "3.3", category: "plug", on_off: true)
  end

  test "index renders" do
    get schedules_path
    assert_response :success
  end

  test "create adds a schedule" do
    assert_difference -> { Schedule.count }, 1 do
      post schedules_path, params: {
        schedule: { device_id: @device.id, action: "turn_on", hour: 19, minute: 0, enabled: true }
      }
    end
    assert_redirected_to schedules_path
  end

  test "destroy removes a schedule" do
    s = Schedule.create!(device: @device, action: "turn_on", hour: 1, minute: 0, enabled: true)
    assert_difference -> { Schedule.count }, -1 do
      delete schedule_path(s)
    end
  end
end
