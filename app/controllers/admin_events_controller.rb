require "report_exporter"

class AdminEventsController < ApplicationController
  before_action :get_event, except: [:index, :annual_events_report]
  before_action :require_admin
  before_action :set_approved_tickets_count, only: [:show]

  #Admin page view with all submitted events and admin statistics:
  def index
    @application_process_options_handler = ApplicationProcessOptionsHandler.find(1)
    @events = Event.all
    @new_users = User.all.created_last_30_days
    @total_organizers = Event.all.total_organizers
    @countries = Event.all.pluck(:country).compact
    @countries_statistics = CountriesStatistics.new(@events).to_json
    @country_rank = CountriesStatistics.new(@events).country_rank
    @categorized_events = {
      "Unapproved events" => Event.unapproved.upcoming.order(:deadline),
      "Approved events" => Event.approved.upcoming.order(:deadline),
      "Past approved events"=> Event.approved.past.order(deadline: :desc).active,
      "Past unapproved events" => Event.unapproved.past.order(:deadline).active
    }
    @approved_events_deadline = {
      "Open deadline:" => Event.approved.upcoming.open.order(:deadline),
      "Closed deadline:" => Event.approved.upcoming.closed.order(:deadline)
    }

    respond_to do |format|
      format.html
      format.csv { send_data ReportExporter.events_report, filename: "events_report_#{DateTime.now.strftime("%F")}.csv" }
    end
  end

  def annual_events_report
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

  #to approve/unapprove an event:
  def approve
    @event.toggle(:approved)
    @event.save!
    if @event.approved?
      tweet_event_check
      inform_applicants_country
      inform_applicants_field_of_interest
      redirect_to admin_url, notice: t('.event_approved', event_name: @event.name)
    else
      redirect_to admin_url, notice: t('.event_unapproved', event_name: @event.name)
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_url
  end

  private

  def get_event
    @event = Event.find(params[:id])
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
