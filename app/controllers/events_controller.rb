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
    @event = Event.approved.find(params[:id])
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

  private
    def event_params
      params.require(:event).permit(
        :organizer_name, :organizer_email, :organizer_email_confirmation,
        :description, :name, :logo, :start_date, :end_date, :approved, :ticket_funded,
        :accommodation_funded, :travel_funded, :deadline, :number_of_tickets,
        :website, :code_of_conduct, :city, :country, :applicant_directions,
        :data_protection_confirmation, :application_link, :application_process,
        :twitter_handle, :state_province)
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
