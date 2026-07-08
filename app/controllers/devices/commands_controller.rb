module Devices
  class CommandsController < ApplicationController
    def create
      device = Device.find(params[:device_id])
      result = CommandRunner.new(device).call(params[:action_name], command_params)
      head :bad_request and return if result[:invalid]

      flash[:alert] = result[:error] unless result[:ok]
      redirect_to root_path
    end

    private

    def command_params
      params.permit(:percent, :r, :g, :b)
    end
  end
end
