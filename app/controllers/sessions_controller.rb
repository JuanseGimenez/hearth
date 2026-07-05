class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    redirect_to root_path and return if logged_in?
  end

  def create
    if ActiveSupport::SecurityUtils.secure_compare(params[:password].to_s, expected_password)
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

  def expected_password
    ENV.fetch("SMART_HOME_PASSWORD", "")
  end
end
