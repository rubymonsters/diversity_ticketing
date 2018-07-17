require "report_exporter"

class AdminEventsController < ApplicationController
  before_action :get_event, except: [:index, :annual_events_report]
  before_action :require_admin

  def index
    @events = Event.all
    @new_users = User.all.created_last_30_days
    @countries = Event.all.group_by(&:country).keys
    @categorized_events = {
      "Unapproved events" => Event.unapproved.upcoming.order(:deadline),
      "Approved events" => Event.approved.upcoming.order(:deadline),
      "Past approved events"=> Event.approved.past.order(:deadline),
      "Past unapproved events" => Event.unapproved.past.order(:deadline)
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

  def approve
    @event.toggle(:approved)
    @event.save!
    if @event.approved?
      tweet_event_check
      inform_applicants_country
      inform_applicants_field_of_interest
      redirect_to admin_url, notice: "#{@event.name} has been approved!"
    else
      redirect_to admin_url, notice: "#{@event.name} has been unapproved!"
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
    Tweet.new(event_id: @event.id, published: false) if params[:approve][:tweet] == "0"
  end
end
