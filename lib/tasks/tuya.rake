require "json"
require "open3"

namespace :tuya do
  desc "Import devices from a tinytuya wizard file (devices.json)"
  task import: :environment do
    path = ENV.fetch("DEVICES_FILE", "devices.json")
    abort "Missing #{path}. Run `.venv/bin/python -m tinytuya wizard` first." unless File.exist?(path)

    JSON.parse(File.read(path)).each do |d|
      device = Device.find_or_initialize_by(tuya_device_id: d["id"])
      device.name ||= d["name"]
      device.local_key = d["key"]
      device.ip = d["ip"] if d["ip"].present?
      device.protocol_version = (d["version"] || "3.3").to_s
      device.category ||= d["name"].to_s =~ /lamp|light|bulb|luz/i ? "light" : "plug"
      device.on_off = true if device.on_off.nil?
      device.save!
      puts "Imported #{device.name} (#{device.tuya_device_id})"
    end
  end

  desc "Rescan the LAN and update device IPs by device id"
  task rescan: :environment do
    script = Rails.root.join("lib/tuya/discover.py").to_s
    stdout, stderr, status = Open3.capture3(TuyaClient.default_python, script)
    abort "Scan failed: #{stderr}" unless status.success?

    JSON.parse(stdout).each do |found|
      device = Device.find_by(tuya_device_id: found["device_id"])
      next unless device
      device.update!(ip: found["ip"])
      puts "Updated #{device.name} → #{found['ip']}"
    end
  end
end
