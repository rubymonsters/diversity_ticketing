require "report_exporter"

class AdminEventsController < ApplicationController
  before_action :get_event, only: [:show, :approve, :edit, :update, :destroy]
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

    respond_to do |format|
      format.html
      format.csv { send_data ReportExporter.events_report, filename: "events_report_#{DateTime.now.strftime("%F")}.csv" }
    end
  end

  def show
    @categorized_applications = {
      "Pending Applications" => @event.applications.submitted.pending,
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
end
