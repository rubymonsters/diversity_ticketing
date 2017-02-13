class AdminEventsController < ApplicationController
  before_action :get_event, only: [:show, :approve, :edit, :update, :destroy]
  before_action :require_admin
  before_action :set_s3_direct_post, only: [:edit, :update]

	def index
    @categorized_events = {
      "Unapproved Events" => Event.unapproved.upcoming.order(deadline: :desc),
      "Approved Events" => Event.approved.upcoming.order(deadline: :desc),
      "Past Approved Events"=> Event.approved.past.order(deadline: :desc),
      "Past Unapproved Events" => Event.unapproved.past.order(deadline: :desc)
    }
  end

  def show
    respond_to do |format|
      format.html
      format.csv { send_data @event.to_csv, filename: "#{@event.name} #{DateTime.now.strftime("%F")}.csv" }
    end
  end

  def approve
    @event.toggle(:approved)
    @event.save
    if @event.approved?
      TwitterWorker.announce_event(@event)
    end
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
        :description, :name, :logo, :start_date, :end_date, :approved, :ticket_funded,
        :accommodation_funded, :travel_funded, :deadline, :number_of_tickets,
        :website, :code_of_conduct, :city, :country, :applicant_directions,
        :application_link, :application_process, :twitter_handle, :state_province)
    end

    def get_event
      @event = Event.find(params[:id])
    end

    def require_admin
      redirect_to root_path unless admin_user?
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
