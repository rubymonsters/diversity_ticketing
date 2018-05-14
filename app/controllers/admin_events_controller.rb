require "report_exporter"

class AdminEventsController < ApplicationController
  before_action :get_event, only: [:show, :approve, :edit, :update, :destroy]
  before_action :require_admin

  def index
    @categorized_events = {
      "Unapproved Events" => Event.unapproved.upcoming.order(:deadline),
      "Approved Events" => Event.approved.upcoming.order(:deadline),
      "Past Approved Events"=> Event.approved.past.order(:deadline),
      "Past Unapproved Events" => Event.unapproved.past.order(:deadline)
    }

    respond_to do |format|
      format.html
      format.csv { send_data ReportExporter.events_report, filename: "events_report_#{DateTime.now.strftime("%F")}.csv" }
    end
  end

  def show
    @categorized_applications = {
      "Pending Applications" => @event.applications.pending,
      "Approved Applications" => @event.applications.approved,
      "Rejected Applications" => @event.applications.rejected
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
      TwitterWorker.announce_event(@event)
    end
    redirect_to admin_url
  end

  def destroy
    @event.destroy
    redirect_to admin_url
  end

  private

    def get_event
      @event = Event.find(params[:id])
    end
end
