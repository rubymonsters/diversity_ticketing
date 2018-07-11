class DraftsController < ApplicationController
  before_action :get_event

  def show
    get_draft
  end

  def edit
    get_draft
  end

  def create
    @draft = Application.new(application_params)
    @draft.event = @event
    set_applicant_id
    save_draft("You have successfully saved an application draft for #{@event.name}.")
  end

  def update
    @draft = @event.applications.find(params[:id])
    @draft.skip_validation = true
    if @draft.update(application_params)
      save_draft("You have successfully saved your changes to the draft.")
    end
  end

  private

  def application_params
    params.require(:application).permit(:name, :email, :email_confirmation, :attendee_info_1,
    :attendee_info_2, :visa_needed, :terms_and_conditions, :applicant_id)
  end

  def get_draft
    @draft = Application.find(params[:id])
  end

  def set_applicant_id
    if signed_in?
      params[:application][:applicant_id] = current_user.id
    end
  end

  def get_event
    @event = Event.find(params[:event_id])
  end

  def save_draft(message)
    @draft.skip_validation = true
    if @draft.save
      redirect_to event_application_path(@event.id, @draft.id),
                  notice: message
    end
  end
end
