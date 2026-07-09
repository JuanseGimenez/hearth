class DevicesController < ApplicationController
  def index
    @devices = Device.order(:name)
  end

  def edit
    @device = Device.find(params[:id])
  end

  def update
    @device = Device.find(params[:id])
    if @device.update(device_params)
      redirect_to root_path, notice: "Saved #{@device.name}"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    device = Device.find(params[:id])
    device.destroy
    redirect_to root_path, notice: "Deleted #{device.name}"
  end

  private

  def device_params
    params.require(:device).permit(:name, :category, :ip, :protocol_version, :on_off, :brightness, :color)
  end
end
