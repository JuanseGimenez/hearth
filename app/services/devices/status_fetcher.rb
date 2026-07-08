module Devices
  class StatusFetcher
    def initialize(device)
      @device = device
    end

    def call
      return { ok: false, error: "no ip" } if @device.ip.blank?

      TuyaClient.new(@device).status
    end
  end
end
