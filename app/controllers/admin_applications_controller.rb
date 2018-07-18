class AdminApplicationsController < ApplicationController
  before_action :require_admin
  before_action :get_application
  before_action :skip_validation, except: [:destroy]

  def show
  end

  def approve
    @application.update_attributes(status: 'approved')
    redirect_to admin_event_path(@application.event_id),
                notice: "#{@application.name}'s application has been approved!"
  end

  def reject
    @application.update_attributes(status: 'rejected')
    redirect_to admin_event_path(@application.event_id),
                flash: { info: "#{@application.name}'s application
                                 has been rejected" }
  end

  def revert
    @application.update_attributes(status: 'pending')
    redirect_to admin_event_path(@application.event_id),
                flash: { info: "#{@application.name}'s application
                                 has been changed to pending" }
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
end
