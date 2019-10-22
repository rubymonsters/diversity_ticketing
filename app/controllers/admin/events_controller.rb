require "report_exporter"

module Admin
  class EventsController < ApplicationController
    before_action :require_admin
    before_action :set_locale_to_english
    before_action :get_event, only: [:show, :edit, :update, :approve, :destroy]
    before_action :set_s3_direct_post, only: [:edit, :update]
    before_action :set_approved_tickets_count, only: [:show]

    # Admin page view with all future events
    def index
      @application_process_options_handler = ApplicationProcessOptionsHandler.find(1)
      @unapproved_events = Event.unapproved.upcoming.order(:deadline)
      @approved_open_events = Event.approved.upcoming.open.order(:deadline)
      @approved_closed_events = Event.approved.upcoming.closed.order(:deadline)

      respond_to do |format|
        format.html
        format.csv { send_data ReportExporter.events_report, filename: "events_report_#{DateTime.now.strftime("%F")}.csv" }
      end
    end

    # Admin page view with all past events
    def past
      @approved_events = Event.approved.past.order(deadline: :desc).active
      @unapproved_events = Event.unapproved.past.order(:deadline).active
    end

    def reports
      @events = Event.all
      @new_users = User.created_last_30_days
      @total_organizers = Event.total_organizers
      @countries = Event.pluck(:country).compact
      @countries_statistics = CountriesStatistics.new(@events).to_json
      @country_rank = CountriesStatistics.new(@events).country_rank
    end

    # Events from current year
    def annual
      respond_to do |format|
        format.csv { send_data ReportExporter.annual_events_report, filename: "anual_events_report_#{DateTime.now.strftime("%F")}.csv" }
      end
    end

    #Event show view for admins (events/:id/admin)- shows event details, an overview over the status of
    #applications (if selection is handled by Travis) and allows selection process for applications as well as csv-download
    def show
      @categorized_applications = {
        "Pending applications" => @event.applications.submitted.pending,
        "Approved applications" => @event.applications.approved,
        "Rejected applications" => @event.applications.rejected
      }

      respond_to do |format|
        format.html
        format.csv { send_data @event.to_csv, filename: "#{@event.name} #{DateTime.now.strftime("%F")}.csv" }
      end
    end

    def edit
    end

    def update
      if @event.update(event_params)
        redirect_to admin_event_path, notice: "You have successfully updated #{@event.name}"
      else
        render :edit
      end
    end

    #to approve/unapprove an event:
    def approve
      @event.toggle(:approved)
      @event.save!
      if @event.approved?
        tweet_event_check
        inform_applicants_country
        inform_applicants_field_of_interest
        redirect_to admin_path, notice: "#{@event.name} has been approved"
      else
        redirect_to admin_path, notice: "#{@event.name} has been unapproved"
      end
    end

    def destroy
      @event.destroy
      redirect_to admin_path
    end

    private

    def get_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit permitted_params_for_admins
    end

    def permitted_params_for_admins
      [
        :organizer_name, :organizer_email, :organizer_email_confirmation,
        :description, :name, :logo, :start_date, :end_date, :ticket_funded,
        :accommodation_funded, :travel_funded, :deadline, :number_of_tickets,
        :website, :code_of_conduct, :city, :country, :applicant_directions,
        :data_protection_confirmation, :application_link, :application_process,
        :twitter_handle, :state_province, :approved_tickets, :locale, :approved,
        { :tag_ids => [] }, tags_attributes: [:id, :name, :category_id]
      ]
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end

    def inform_applicants_country
      User.where(country: @event.country).where(country_email_notifications: true).each do |user|
        UserNotificationsMailer.new_local_event(@event, user).deliver_later
      end
    end

    def inform_applicants_field_of_interest
      @event.interested_users.where(tag_email_notifications: true).each do |user|
        UserNotificationsMailer.new_field_specific_event(@event, user).deliver_later
      end
    end

    def tweet_event_check
      Tweet.create(event_id: @event.id, published: false) if params[:approve][:tweet] == "0"
    end

    def set_approved_tickets_count
      if @event.approved_tickets == 0
        approved_tickets = Application.where(event_id: @event.id, status: 'approved').count
        @event.update_attributes(approved_tickets: approved_tickets)
      end
    end
  end
end
