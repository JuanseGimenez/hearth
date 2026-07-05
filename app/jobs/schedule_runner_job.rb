class ScheduleRunnerJob < ApplicationJob
  queue_as :default

  def perform(time = Time.current)
    Schedule.due(time).each do |schedule|
      run(schedule)
    rescue StandardError => e
      Rails.logger.error("ScheduleRunnerJob: schedule #{schedule.id} failed: #{e.message}")
    end
  end

  private

  def run(schedule)
    client = TuyaClient.new(schedule.device)
    params = (schedule.params || {}).symbolize_keys
    case schedule.action
    when "turn_on"        then client.turn_on
    when "turn_off"       then client.turn_off
    when "set_brightness" then client.set_brightness(params[:percent])
    when "set_color"      then client.set_color(**params.slice(:r, :g, :b))
    end
  end
end
