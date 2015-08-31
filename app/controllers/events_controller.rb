class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def admin_index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
 
    if @event.save
      redirect_to @event
    else
      render :new
    end
  end

  private
    def event_params
      params.require(:event).permit(:organizer_name, :organizer_email, :organizer_email_confirmation, :description, :name, :start_date, :end_date, :question_1, :question_2, :question_3)
    end
end
