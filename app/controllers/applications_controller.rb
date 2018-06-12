class ApplicationsController < ApplicationController
  before_action :require_admin, only: [:admin_destroy]
  before_action :get_event
  before_action :get_application, except: [:new, :create, :continue_as_guest]
  before_action :ensure_correct_user, only: [:show, :edit]
  before_action :skip_validation, only: [:save_draft, :approve, :reject, :revert]
  skip_before_action :require_login, only: [:new, :create, :continue_as_guest]

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
    elsif params[:commit] == 'Save Changes'
      save_draft
    else
      render :edit
    end
  end

  def submit
    if @application.update(application_params)
      @application.update_attributes(submitted: true)
      ApplicantMailer.application_received(@application).deliver_later
      current_user ? (path = event_application_path(@event.id, @application.id)) : (path = @event)
      redirect_to path, notice: "You have successfully applied for #{@event.name}."
    else
      render :show
    end
  end

  def save_draft
    @application.skip_validation = true
    if Application.find_by(id: @application.id)
      message = "You have successfully saved your changes to the draft."
    else
      message = "You have successfully saved an application draft for #{@event.name}."
    end
    if @application.save
      redirect_to event_application_path(@event.id, @application.id), notice: message
    end
  end

  def new
    if @event.application_process == 'application_by_organizer'
      redirect_to @event
    elsif !current_user && request.env["HTTP_REFERER"] != continue_as_guest_url(@event)
      redirect_to continue_as_guest_path(@event)
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
      @application.status = 'pending'
      if @application.save && params[:commit] == 'Submit Application'
        submit
      elsif params[:commit] == 'Save as a Draft'
        save_draft
      else
        render :new
      end
    end
  end

  def approve
    @application.update_attributes(status: "approved")
    redirect_to admin_event_path(@application.event_id), notice: "#{@application.name}'s application has been approved!"
  end

  def reject
    @application.update_attributes(status: "rejected")
    redirect_to admin_event_path(@application.event_id), flash: { :info => "#{@application.name}'s application has been rejected" }
  end


  def revert
    @application.update_attributes(status: "pending")
    redirect_to admin_event_path(@application.event_id), flash: { :info => "#{@application.name}'s application has been changed to pending" }
  end

  def destroy
    @application.destroy
    redirect_to user_applications_path(current_user.id)
  end

  def admin_destroy
    @application.destroy
    redirect_to event_admin_path(@event.id)
  end

  def continue_as_guest
    if request.env["HTTP_REFERER"] == (sign_in_url || sign_up_url)
      redirect_to new_event_application_path(@event.id)
    else
      render :continue_as_guest
    end
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

    def skip_validation
      @application.skip_validation = true
    end
end
