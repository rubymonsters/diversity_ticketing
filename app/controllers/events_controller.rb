class EventsController < ApplicationController   
  http_basic_authenticate_with name: ENV['DT_USERNAME'], password: ENV['DT_PASSWORD'], only: [:admin_index, :admin_show, :edit]
  before_action :get_event, only: [:admin_show, :edit, :update]

  def index
    @events = Event.approved
  end

  def admin_index
    @events = Event.all
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
      redirect_to events_url, notice: "You have successfully created an event."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to admin_path
    else
      render :edit
    end
  end

  private
    def event_params
      params.require(:event).permit(:organizer_name, :organizer_email, :organizer_email_confirmation, :description, :name, :start_date, :end_date, :question_1, :question_2, :question_3, :approved)
    end

    def get_event
      @event = Event.find(params[:id])
    end
end
