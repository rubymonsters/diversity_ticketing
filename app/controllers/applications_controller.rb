class ApplicationsController < ApplicationController
  before_action :get_event, only: [:show, :new, :create, :destroy]
  skip_before_action :authenticate, only: [:new, :create]

  def show
    @application = @event.applications.find(params[:id])
  end

	def new
    @application = @event.applications.build
	end

  def create
    @application = Application.new(application_params)
    @application.event = @event
    if @application.save
      redirect_to @event, notice: "You have successfully applied for #{@event.name}."
    else
      render :new
    end
  end

  def destroy
    @application = Application.find(params[:id])
    @application.destroy
    redirect_to event_admin_path(@event.id)
  end

  private
    def application_params
      params.require(:application).permit(:name, :email, :email_confirmation, :attendee_info_1, :attendee_info_2, :terms_and_conditions)
    end

    def get_event
      @event = Event.find(params[:event_id])
    end
end
