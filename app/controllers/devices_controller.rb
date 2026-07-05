class DevicesController < ApplicationController
  ALLOWED = %w[turn_on turn_off set_brightness set_color].freeze
  PROTOCOL_VERSIONS = %w[3.3 3.4 3.5].freeze

  def index
    @devices = Device.order(:name)
  end

  def edit
    @device = Device.find(params[:id])
  end

  def update
    @device = Device.find(params[:id])
    if @device.update(device_params)
      redirect_to root_path, notice: "Saved #{@device.name}"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    device = Device.find(params[:id])
    device.destroy
    redirect_to root_path, notice: "Deleted #{device.name}"
  end

  def detect_version
    device = Device.find(params[:id])
    if device.ip.blank?
      redirect_to edit_device_path(device), alert: "Set and save the IP first" and return
    end

    found = PROTOCOL_VERSIONS.find do |version|
      device.protocol_version = version
      TuyaClient.new(device).status[:ok]
    end

    if found
      device.update!(protocol_version: found)
      redirect_to edit_device_path(device), notice: "Detected protocol version #{found}"
    else
      redirect_to edit_device_path(device), alert: "Could not reach the device on any protocol version"
    end
  end

  def status
    device = Device.find(params[:id])
    result = device.ip.blank? ? { ok: false, error: "no ip" } : TuyaClient.new(device).status
    render partial: "devices/status", locals: { device: device, result: result }
  end

  def command
    device = Device.find(params[:id])
    action = params[:action_name].to_s
    head :bad_request and return unless ALLOWED.include?(action)

    client = TuyaClient.new(device)
    result =
      case action
      when "turn_on"        then client.turn_on
      when "turn_off"       then client.turn_off
      when "set_brightness" then client.set_brightness(params[:percent])
      when "set_color"      then client.set_color(r: params[:r], g: params[:g], b: params[:b])
      end

    flash[:alert] = result[:error] unless result[:ok]
    redirect_to root_path
  end

  private

  def device_params
    params.require(:device).permit(:name, :category, :ip, :protocol_version, :on_off, :brightness, :color)
  end
end
