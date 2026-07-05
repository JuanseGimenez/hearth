class DevicesController < ApplicationController
  ALLOWED = %w[turn_on turn_off set_brightness set_color].freeze

  def index
    @devices = Device.order(:name)
  end

  def command
    device = Device.find(params[:id])
    action = params[:action_name].to_s
    head :bad_request and return unless ALLOWED.include?(action)

    client = TuyaClient.new(device)
    result =
      case action
      when "set_brightness" then client.set_brightness(params[:percent])
      when "set_color"      then client.set_color(r: params[:r], g: params[:g], b: params[:b])
      else client.public_send(action)
      end

    flash[:alert] = result[:error] unless result[:ok]
    redirect_to root_path
  end
end
