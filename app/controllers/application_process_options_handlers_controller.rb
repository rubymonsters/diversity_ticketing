#This controller manages the enabling and disabling of selection process by DT
class ApplicationProcessOptionsHandlersController < ApplicationController
  before_action :require_admin

  def update
    @application_process_options_handler = ApplicationProcessOptionsHandler.find(1)
    if @application_process_options_handler.update(application_process_options_handler_params)
      redirect_to admin_url,
      notice: "Application process options successfully updated"
    else
      redirect_to admin_url, notice: "Application process options could not be updated. Please try again."
    end
  end

  private

  def application_process_options_handler_params
    params.require(:application_process_options_handler).permit(:selection_by_dt_enabled)
  end
end
