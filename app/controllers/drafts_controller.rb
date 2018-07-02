class DraftsController < ApplicationController
  before_action :get_event

  def new
  end

  def create
    @application = Application.new(application_params)
    @application.event = @event
    save_draft("You have successfully saved an application draft for #{@event.name}.")
  end

  def update
    @application = @event.applications.find(params[:id])
    @application.skip_validation = true
    @application.update(application_params)
    save_draft("You have successfully saved your changes to the draft.")
  end

  def save_draft(message)
    @application.skip_validation = true
    if @application.save
      redirect_to event_application_path(@event.id, @application.id),
                  notice: message
    end
  end

  private

  def application_params
    set_applicant_id
    params.require(:application).permit(:name, :email, :email_confirmation, :attendee_info_1,
    :attendee_info_2, :visa_needed, :terms_and_conditions, :applicant_id)
  end

  def set_applicant_id
    if signed_in?
      params[:application][:applicant_id] = current_user.id
    end
  end

  def get_event
    @event = Event.find(params[:event_id])
  end
end
