module Devices
  class StatusesController < ApplicationController
    def show
      device = Device.find(params[:device_id])
      result = StatusFetcher.new(device).call
      render partial: "devices/status", locals: { device: device, result: result }
    end
  end
end
