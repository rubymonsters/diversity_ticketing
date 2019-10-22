#This controller manages the selection process of applications for a specific event (if selection
#process is being handled by this app), only accessable for admins.
module Admin
  class ApplicationsController < ApplicationController
    before_action :require_admin
    before_action :set_locale_to_english
    before_action :get_application
    before_action :skip_validation, except: [:destroy]

    def show
      if @application.event.deleted?
        redirect_to(
          admin_path,
          notice: "You cannot view your application as the event you applied for has been removed "\
            "from Diversity Tickets"
        )
      elsif @application.draft?
        redirect_to admin_event_path(@application.event), notice: "You cannot view a draft."
      end
    end

    # to approve an application
    def approve
      get_event
      @application.update_attributes(status: 'approved')
      add_to_approved_tickets_count
      redirect_to admin_event_path(@application.event_id),
                  notice: "#{ @application.name}'s application has been approved"
    end

    # to reject an application
    def reject
      @application.update_attributes(status: 'rejected')
      redirect_to admin_event_path(@application.event_id),
                  flash: { info: "#{ @application.name}'s application has been rejected" }
    end

    # to set an application back to pending
    def revert
      remove_from_approved_tickets_count
      @application.update_attributes(status: 'pending')
      redirect_to admin_event_path(@application.event_id),
                  flash: { info: "#{ @application.name}'s application has been changed to pending" }
    end

    def destroy
      @application.destroy
      redirect_to admin_event_path(@event.id)
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
end
