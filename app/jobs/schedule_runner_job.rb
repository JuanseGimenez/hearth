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
    Devices::CommandRunner.new(schedule.device).call(schedule.action, schedule.params || {})
  end
end
