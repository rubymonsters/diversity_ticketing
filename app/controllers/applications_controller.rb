class ApplicationsController < ApplicationController
  before_action :require_admin, only: [:destroy]
  before_action :get_event, only: [:show, :edit, :update, :new, :create, :destroy, :ensure_correct_user]
  before_action :get_application, only: [:edit, :show, :update, :destroy, :ensure_correct_user]
  before_action :ensure_correct_user, only: [:show, :edit]
  skip_before_action :require_login, only: [:new, :create]

  def show
  end

  def edit
    if @event.closed?
      redirect_to event_application_path(@event.id, @application.id),
      alert: "You cannot edit your application as the #{@event.name} deadline has already passed"
    end
  end

  def update
    if @application.update(application_params)
      redirect_to event_application_path(@event.id, @application.id),
      notice: "You have successfully updated your application for #{@event.name}."
    else
      render :edit
    end
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
      if @application.save && params[:commit] == 'Submit Application'
        @application.update_attributes(submitted: true)
        ApplicantMailer.application_received(@application).deliver_later
        redirect_to @event, notice: "You have successfully applied for #{@event.name}."
      elsif @application.save && params[:commit] == 'Save as a Draft'
        redirect_to @event, notice: "You have successfully saved an application draft for #{@event.name}."
      else
        render :new
      end
    end
  end

  def destroy
    @application.destroy
    redirect_to event_admin_path(@event.id)
  end

  private
    def application_params
      set_applicant_id
      params.require(:application).permit(:name, :email, :email_confirmation, :attendee_info_1,
      :attendee_info_2, :visa_needed, :terms_and_conditions, :applicant_id)
    end

    def get_application
      @application = @event.applications.find(params[:id])
    end

    def get_event
      @event = Event.find(params[:event_id])
    end

    def ensure_correct_user
      @applicant = User.find_by(id: Application.find(params[:id]).applicant_id)
      unless @applicant == current_user || (admin_user? && @application.submitted)
        redirect_to root_path
      end
    end

    def set_applicant_id
      if signed_in?
        params[:application][:applicant_id] = current_user.id
      end
    end
end
