require "json"
require "open3"

# Ruby wrapper over the Python tinytuya bridge. Consumers never see Python.
class TuyaClient
  DEFAULT_BRIDGE = Rails.root.join("lib/tuya/bridge.py").to_s

  def initialize(device, python: "python3", bridge_path: DEFAULT_BRIDGE)
    @device = device
    @python = python
    @bridge_path = bridge_path
  end

  def status = command("status")
  def turn_on = command("turn_on")
  def turn_off = command("turn_off")
  def set_brightness(percent) = command("set_brightness", percent: percent.to_i)
  def set_color(r:, g:, b:) = command("set_color", r: r.to_i, g: g.to_i, b: b.to_i)

  private

  def command(action, **params)
    payload = {
      device_id: @device.tuya_device_id,
      ip: @device.ip,
      local_key: @device.local_key,
      version: @device.protocol_version,
      category: @device.category,
      action: action,
      params: params
    }
    stdout, stderr, status = Open3.capture3(@python, @bridge_path, stdin_data: payload.to_json)
    return { ok: false, error: stderr.presence || "bridge failed" } unless status.success?

    parse(stdout)
  rescue StandardError => e
    { ok: false, error: e.message }
  end

  def parse(stdout)
    data = JSON.parse(stdout)
    { ok: data["ok"], state: data["state"], error: data["error"] }.compact
  rescue JSON::ParserError
    { ok: false, error: "invalid bridge response" }
  end
end
