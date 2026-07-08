module Devices
  # Dispatches a Tuya command for a device. Single source of truth for the set
  # of allowed actions, shared by the web controller and the scheduler job.
  class CommandRunner
    ALLOWED = %w[turn_on turn_off set_brightness set_color].freeze

    def initialize(device)
      @device = device
    end

    def call(action, params = {})
      action = action.to_s
      return { ok: false, invalid: true } unless ALLOWED.include?(action)

      params = params.to_h.symbolize_keys
      client = TuyaClient.new(@device)
      case action
      when "turn_on"        then client.turn_on
      when "turn_off"       then client.turn_off
      when "set_brightness" then client.set_brightness(params[:percent])
      when "set_color"      then client.set_color(r: params[:r], g: params[:g], b: params[:b])
      end
    end
  end
end
