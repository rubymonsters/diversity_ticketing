#This controller manages the applications for a specific event
class ApplicationsController < ApplicationController
  before_action :get_event
  before_action :get_application, except: [:new, :create, :continue_as_guest]
  before_action :ensure_correct_user, only: [:show, :edit]
  skip_before_action :require_login, only: [:new, :create, :continue_as_guest]

  def new
    if !current_user && !guest
      redirect_to continue_as_guest_path(@event.id)
    else
      unless current_user && @event.applications.find_by(applicant_id: current_user.id)
        @application = @event.applications.build
      else
        redirect_to user_applications_path(current_user.id)
      end
    end
  end

  def create
    if current_user && @event.applications.find_by(applicant_id: current_user.id)
      redirect_to @event, alert: t('.already_applied', event_name: @event.name)
    else
      @application = Application.new(application_params)
      @application.event = @event
      set_applicant_id
      if @application.save
        submit
      else
        render :new
      end
    end
  end

  def show
    if @application.deleted
      redirect_to user_applications_path(current_user.id),
      alert: t('.application_deleted')
    end
  end

  def edit
    if @event.closed?
      redirect_to event_application_path(@event.id, @application.id),
      alert: t('.edit_deadline_passed', event_name: @event.name)
    end
  end

  def update
    if @application.update(application_params)
      redirect_to event_application_path(@event.id, @application.id),
      notice: t('.update_success', event_name: @event.name)
    else
      render :edit
    end
  end

  def submit
    if @application.update(application_params)
      @application.update_attributes(submitted: true)
      ApplicantMailer.application_received(@application).deliver_later
      ticket_capacity_check
      current_user ? (path = event_application_path(@event.id, @application.id)) : (path = @event)
      redirect_to path, notice: t('.application_success', event_name: @event.name)
    else
      render :show
    end
  end

  def destroy
    @application.destroy
    redirect_to user_applications_path(current_user.id)
  end

  #If current user is signed in redirect to applications#new, otherwise show continue_as_guest page
  #to give user the option to sign in/up or choose to proceed as guest without a user_id.
  def continue_as_guest
    if current_user
      redirect_to new_event_application_path(event_id: params[:event_id])
    else
      @guest = true
      render :continue_as_guest
    end
  end

  private

  def application_params
    params.require(:application).permit(:name, :email, :email_confirmation, :attendee_info_1,
    :attendee_info_2, :visa_needed, :terms_and_conditions, :applicant_id, :locale, :event_id)
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

  def guest
    params[:guest]
  end

  def ticket_capacity_check
    if @event.number_of_tickets == @event.applications.count - 1
      if (@event.organizer.capacity_email_notifications == "Always") || (@event.organizer.capacity_email_notifications == "Once" && @event.capacity_reminder_count == 0)
        OrganizerMailer.ticket_capacity_reached(@event).deliver_later
        @event.update_attributes(capacity_reminder_count: @event.capacity_reminder_count + 1)
      end
    end
  end
end
