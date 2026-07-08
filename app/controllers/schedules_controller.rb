class SchedulesController < ApplicationController
  def index
    @schedules = Schedule.includes(:device).order(:hour, :minute)
    @schedule = Schedule.new
    @devices = Device.order(:name)
  end

  def create
    schedule = Schedule.new(schedule_params)
    if schedule.save
      redirect_to schedules_path
    else
      redirect_to schedules_path, alert: schedule.errors.full_messages.to_sentence
    end
  end

  def update
    Schedule.find(params[:id]).toggle_enabled!
    redirect_to schedules_path
  end

  def destroy
    Schedule.find(params[:id]).destroy
    redirect_to schedules_path
  end

  private

  def schedule_params
    params.require(:schedule).permit(:device_id, :action, :hour, :minute, :days_of_week, :enabled, params: {})
  end
end
