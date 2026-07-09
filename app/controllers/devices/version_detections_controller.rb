module Devices
  class VersionDetectionsController < ApplicationController
    def create
      device = Device.find(params[:device_id])
      case VersionDetector.new(device).call
      in { status: :no_ip }
        redirect_to edit_device_path(device), alert: "Set and save the IP first"
      in { status: :detected, version: }
        redirect_to edit_device_path(device), notice: "Detected protocol version #{version}"
      in { status: :not_found }
        redirect_to edit_device_path(device), alert: "Could not reach the device on any protocol version"
      end
    end
  end
end
