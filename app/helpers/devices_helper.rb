module DevicesHelper
  # The Tuya DP that carries on/off differs by device type: bulbs report it on
  # DP "20", plugs/outlets on DP "1". Try the likely one first, then the other.
  POWER_KEYS = { "light" => %w[20 1], "plug" => %w[1 20] }.freeze

  # Maps a TuyaClient#status result to :on / :off / :unreachable / :unknown.
  def device_power_state(device, result)
    return :unreachable unless result && result[:ok]

    dps = result[:state] || {}
    key = (POWER_KEYS[device.category] || %w[1 20]).find { |k| dps.key?(k) }
    return :unknown if key.nil?

    dps[key] ? :on : :off
  end

  def device_power_label(state)
    { on: "On", off: "Off", unreachable: "Unreachable", unknown: "Unknown" }.fetch(state, "Unknown")
  end

  def device_icon(device)
    device.category == "light" ? "💡" : "🔌"
  end
end
