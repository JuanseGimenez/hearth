class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    redirect_to root_path and return if logged_in?
  end

  def create
    if authenticated?(params[:password])
      reset_session
      session[:authenticated] = true
      redirect_to root_path
    else
      flash.now[:alert] = "Wrong password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end

  private

  def authenticated?(submitted)
    expected = ENV["SMART_HOME_PASSWORD"].to_s
    return false if expected.blank?

    ActiveSupport::SecurityUtils.secure_compare(submitted.to_s, expected)
  end
end
