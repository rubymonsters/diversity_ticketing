class ApplicationsController < ApplicationController
	def new
		 @event = Event.find(params[:event_id])
	end

  def create
    @event = Event.find(params[:event_id])

    @application = Application.new(application_params)
    @application.event_id = params[:event_id]
    @application.save
    redirect_to @event
  end

  private
    def application_params
      params.require(:application).permit(:name, :email, :answer_1, :answer_2, :answer_3)
    end
end
