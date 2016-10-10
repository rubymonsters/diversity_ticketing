class EventsController < ApplicationController
  before_action :set_s3_direct_post, only: [:new, :preview, :edit, :create, :update]
  skip_before_action :require_login, only: [:index, :index_past, :show]

  def index
    @open_events   = Event.approved.upcoming.open.order(:deadline)
    @closed_events = Event.approved.upcoming.closed.order(:deadline)
    @past_events   = Event.approved.past
  end

  def index_past
    @events = Event.approved.past
  end

  def show
    @event = Event.find(params[:id])
    unless @event.approved || @event.organizer_id == current_user.id
      redirect_to :back, alert: "You are not allowed to access this event."
    end
  end

  def new
    @event = Event.new
  end

  def preview
    @event = Event.new(ApplicationProcess::Params.clean(event_params))

    if @event.valid?
      render :preview
    else
      render :new
    end
  end

  def create
    @event = Event.new(ApplicationProcess::Params.clean(event_params))
    @event.organizer_id = current_user.id

    if @event.save
      User.admin.each do |user|
        AdminMailer.submitted_event(@event, user.email).deliver_later
      end
      OrganizerMailer.submitted_event(@event).deliver_later
      redirect_to events_url, notice: "Thank you for submitting #{@event.name}. We will review it shortly."
    else
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])

    unless current_user.admin? || !@event.approved && @event.open?
      redirect_to :show, alert: "Your event can't be edited, because it has already been approved, or the deadline has passed."
    end
  end

  def update
    @event = Event.find(params[:id])

    if @event.update(event_params)
      if current_user.admin?
        redirect_to admin_path, notice: "You have successfully updated #{@event.name}."
      else
        redirect_to user_path(current_user), notice: "You have successfully updated #{@event.name}."
      end
    else
      render :edit
    end
  end

  private
    def event_params
      permitted_params_for_event_organizers = [:organizer_name, :organizer_email, :organizer_email_confirmation,
          :description, :name, :logo, :start_date, :end_date, :ticket_funded,
          :accommodation_funded, :travel_funded, :deadline, :number_of_tickets,
          :website, :code_of_conduct, :city, :country, :applicant_directions,
          :data_protection_confirmation, :application_link, :application_process]
      permitted_params_for_admins = permitted_params_for_event_organizers + [:approved]

      if current_user.admin?
        params.require(:event).permit permitted_params_for_admins
      elsif @event && @event.approved?
        params.require(:event).permit()
      else
        params.require(:event).permit permitted_params_for_event_organizers
      end
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
