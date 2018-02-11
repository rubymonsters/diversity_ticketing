class ApplicationsController < ApplicationController
  before_action :require_admin, only: [:show, :destroy]
  before_action :get_event, only: [:show, :new, :create, :destroy]
  skip_before_action :require_login, only: [:new, :create]

  def show
    @application = @event.applications.find(params[:id])
  end

  def new
    if @event.application_process == 'application_by_organizer'
      redirect_to @event
    else
      @application = @event.applications.build
    end
  end

  def create
    if @event.application_process == 'application_by_organizer'
      redirect_to @event
    else
      @application = Application.new(application_params)
      @application.event = @event
      if @application.save
        ApplicantMailer.application_received(@application).deliver_later
        redirect_to @event, notice: "You have successfully applied for #{@event.name}."
      else
        render :new
      end
    end
  end

  def destroy
    @application = Application.find(params[:id])
    @application.destroy
    redirect_to event_admin_path(@event.id)
  end

  private
    def application_params
      params.require(:application).permit(:name, :email, :email_confirmation, :attendee_info_1,
        :attendee_info_2, :visa_needed, :terms_and_conditions)
    end

    def get_event
      @event = Event.find(params[:event_id])
    end
end
