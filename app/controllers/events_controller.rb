class EventsController < ApplicationController
  skip_before_action :require_login, only: [:index, :index_past, :show, :create, :new, :preview]
  before_action :set_s3_direct_post, only: [:new, :preview, :edit, :create, :update]

  def index
    @events = Event.approved.upcoming
    @past_events = Event.approved.past
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
    @event = Event.new(event_params)

    if @event.valid?
      render :preview
    else
      render :new
    end
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      User.admin.each do |user|
        AdminMailer.submitted_event(@event, user.email).deliver_later
      end
      OrganizerMailer.submitted_event(@event).deliver_later
      redirect_to events_url, notice: "You have successfully created #{@event.name}."
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
        :selection_by_organizer, :data_protection_confirmation)
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
