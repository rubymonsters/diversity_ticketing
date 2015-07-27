class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
  end

  def create
    @event = Event.new(event_params)
 
    @event.save
    redirect_to @event
  end

  private
    def event_params
      params.require(:event).permit(:organizer_name, :organizer_email, :description, :name, :date, :question_1, :question_2, :question_3)
    end
end
