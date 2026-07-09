class PasswordAuthenticator
  def self.call(submitted) = new(submitted).call

  def initialize(submitted)
    @submitted = submitted
  end

  def call
    expected = ENV["SMART_HOME_PASSWORD"].to_s
    return false if expected.blank?

    ActiveSupport::SecurityUtils.secure_compare(@submitted.to_s, expected)
  end
end
