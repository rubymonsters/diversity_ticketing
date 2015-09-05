class EventsController < ApplicationController   
  http_basic_authenticate_with name: ENV['username'], password: ENV['password'], only: [:admin_index, :edit]

  def index
    @events = Event.where(approved: true)
  end

  def admin_index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])

    if @event.approved
      render :show
    else
      redirect_to events_path
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
 
    if @event.save
      redirect_to events_path
    else
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])

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
end
