class ApplicationsController < ApplicationController
  def show
    @event = Event.find(params[:event_id])
    @application = Application.find(params[:id])
  end

	def new
		@event = Event.find(params[:event_id])
	end

  def create
    @event = Event.find(params[:event_id])

    @application = Application.new(application_params)
    @application.event_id = params[:event_id]
    @application.save
    redirect_to event_application_path(@event, @application)
  end

  private
    def application_params
      params.require(:application).permit(:name, :email, :answer_1, :answer_2, :answer_3)
    end
end
