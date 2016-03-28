class AdminEventsController < ApplicationController
  before_action :get_event, only: [:show, :approve, :edit, :update, :destroy]
  before_action :require_admin

	def index
    @categorized_events = {
      "Unapproved Events" => Event.unapproved,
      "Approved Events" => Event.approved.upcoming,
      "Past Events"=> Event.approved.past
    }
  end

  def show
    respond_to do |format|
      format.html
      format.csv { send_data @event.to_csv, filename: "#{@event.name} #{DateTime.now.strftime("%F")}.csv" }
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

  def approve
    @event.toggle(:approved)
    @event.save
    redirect_to admin_url
  end

  def destroy
    @event.destroy
    redirect_to admin_url
  end

  private
    def event_params
      params.require(:event).permit(
        :organizer_name, :organizer_email, :organizer_email_confirmation,
        :description, :name, :start_date, :end_date, :approved, :ticket_funded,
        :accommodation_funded, :travel_funded, :deadline, :number_of_tickets,
        :website, :code_of_conduct, :city, :country, :applicant_directions)
    end

    def get_event
      @event = Event.find(params[:id])
    end

    def require_admin
      if current_user == nil
        redirect_to sign_in_path
      elsif !current_user.admin?
        redirect_to root_path
      end
    end
end
