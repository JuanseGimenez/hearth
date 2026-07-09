class Schedule < ApplicationRecord
  belongs_to :device

  ACTIONS = %w[turn_on turn_off set_brightness set_color].freeze
  validates :action, inclusion: { in: ACTIONS }
  validates :hour, inclusion: { in: 0..23 }
  validates :minute, inclusion: { in: 0..59 }

  scope :enabled, -> { where(enabled: true) }

  def self.due(time)
    enabled.where(hour: time.hour, minute: time.min).select { |s| s.runs_on?(time.wday) }
  end

  def runs_on?(wday)
    return true if days_of_week.blank?
    days_of_week.split(",").map(&:strip).map(&:to_i).include?(wday)
  end

  def toggle_enabled!
    update(enabled: !enabled)
  end
end
