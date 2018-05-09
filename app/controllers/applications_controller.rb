class ApplicationsController < ApplicationController
  before_action :require_admin, only: [:admin_destroy]
  before_action :get_event
  before_action :get_application, except: [:new, :create]
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
    if @application.update(application_params) && params[:commit] == 'Apply Changes'
      redirect_to event_application_path(@event.id, @application.id),
      notice: "You have successfully updated your application for #{@event.name}."
    elsif @application.update(application_params) && params[:commit] == 'Save Changes'
      redirect_to event_application_path(@event.id, @application.id),
      notice: "You have successfully saved your changes to the draft."
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
    elsif current_user && @event.applications.find_by(applicant_id: current_user.id)
      redirect_to @event, alert: "You have already applied for #{@event.name}"
    else
      @application = Application.new(application_params)
      @application.event = @event
      if @application.save && params[:commit] == 'Submit Application'
        @application.update_attributes(submitted: true)
        ApplicantMailer.application_received(@application).deliver_later
        current_user ? (path = event_application_path(@event.id, @application.id)) : (path = @event)
        redirect_to path, notice: "You have successfully applied for #{@event.name}."
      elsif @application.save && params[:commit] == 'Save as a Draft'
        redirect_to event_application_path(@event.id, @application.id), notice: "You have successfully saved an application draft for #{@event.name}."
      else
        render :new
      end
    end
  end

  def submit
    @application.skip_validation = true
    @application.update_attributes(submitted: true)
    redirect_to user_applications_path(@application.applicant_id), notice: "You have successfully submitted an application for #{@event.name}."
  end

  def approve
    @application.skip_validation = true
    @application.update_attributes(status: "approved")
    redirect_to admin_event_path(@application.event_id), notice: "You have successfully submitted an application for #{@event.name}."
  end

  def destroy
    @application.destroy
    redirect_to user_applications_path(current_user.id)
  end

  def admin_destroy
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
      @applicant = User.find_by(id: @application.applicant_id)
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
