class AdminApplicationsController < ApplicationController
  before_action :require_admin
  before_action :get_application
  before_action :skip_validation, except: [:destroy]

  def show
  end

  def approve
    get_event
    @application.update_attributes(status: 'approved')
    add_to_approved_tickets_count
    redirect_to admin_event_path(@application.event_id),
                notice: t('.application_approved', application_name: @application.name)
  end

  def reject
    @application.update_attributes(status: 'rejected')
    redirect_to admin_event_path(@application.event_id),
                flash: { info: t('.application_rejected', application_name: @application.name) }
  end

  def revert
    remove_from_approved_tickets_count
    @application.update_attributes(status: 'pending')
    redirect_to admin_event_path(@application.event_id),
                flash: { info: t('.application_pending', application_name: @application.name) }
  end

  def destroy
    @application.destroy
    redirect_to event_admin_path(@event.id)
  end

  private

  def get_application
    get_event
    @application = @event.applications.find(params[:id])
  end

  def get_event
    @event = Event.find(params[:event_id])
  end

  def skip_validation
    @application.skip_validation = true
  end

  def add_to_approved_tickets_count
    @event.update_attributes(approved_tickets: @event.approved_tickets + 1)
  end

  def remove_from_approved_tickets_count
    if @application.status == 'approved'
      @event.update_attributes(approved_tickets: @event.approved_tickets - 1)
    end
  end
end
