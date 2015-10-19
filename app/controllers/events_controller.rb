class EventsController < ApplicationController   
  skip_before_action :authenticate, only: [:index, :index_past, :show, :create, :new]
  before_action :get_event, only: [:admin_show, :edit, :update, :destroy]

  def index
    @events = Event.approved.upcoming
  end

  def index_past
    @events = Event.approved.past
  end

  def admin_index
    @categorized_events = {
      "Unapproved Events" => Event.unapproved,
      "Approved Events" => Event.approved.upcoming, 
      "Past Events"=> Event.approved.past 
    }
  end

  def admin_show
    respond_to do |format|
      format.html
      format.csv { send_data @event.to_csv }
    end
  end

  def show
    @event = Event.approved.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
 
    if @event.save
      redirect_to events_url, notice: "You have successfully created #{@event.name}."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to admin_path, notice: "You have successfully updated #{@event.name}."
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_url
  end

  private
    def event_params
      params.require(:event).permit(:organizer_name, :organizer_email, :organizer_email_confirmation, :description, :name, :start_date, :end_date, :question_1, :question_2, :question_3, :approved)
    end

    def get_event
      @event = Event.find(params[:id])
    end
end
