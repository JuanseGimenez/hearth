class Device < ApplicationRecord
  CATEGORIES = %w[plug light].freeze
  CAPABILITIES = %i[on_off brightness color].freeze

  validates :name, :tuya_device_id, :local_key, :protocol_version, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  def supports?(capability)
    CAPABILITIES.include?(capability) && !!public_send(capability)
  end
end
