class EventsController < ApplicationController
  skip_before_action :require_login, only: [:index, :index_past, :show, :create, :new, :preview]

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
        :description, :name, :start_date, :end_date, :approved, :ticket_funded,
        :accommodation_funded, :travel_funded, :deadline, :number_of_tickets,
        :website, :code_of_conduct, :city, :country, :applicant_directions,
        :selection_by_organizer, :data_protection_confirmation)
    end
end
