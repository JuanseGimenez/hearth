module Devices
  # Probes each supported protocol version against the device and persists the
  # first one that responds.
  class VersionDetector
    PROTOCOL_VERSIONS = %w[3.3 3.4 3.5].freeze

    def initialize(device)
      @device = device
    end

    def call
      return { status: :no_ip } if @device.ip.blank?

      found = PROTOCOL_VERSIONS.find do |version|
        @device.protocol_version = version
        TuyaClient.new(@device).status[:ok]
      end

      if found
        @device.update!(protocol_version: found)
        { status: :detected, version: found }
      else
        { status: :not_found }
      end
    end
  end
end
