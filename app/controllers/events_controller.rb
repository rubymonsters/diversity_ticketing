class EventsController < ApplicationController
  before_action :set_s3_direct_post, only: [:new, :preview, :edit, :create, :update]
  before_action :get_event, only: [:show, :edit, :update, :destroy, :delete_event_data, :delete_event_applications_data]
  skip_before_action :require_login, only: [:index, :index_past, :show, :destroy]

  def index
    @open_events   = Event.approved.upcoming.open.order(:deadline)
    @closed_events = Event.approved.upcoming.closed.order(:deadline)
    @past_events   = Event.approved.past.active
  end

  def index_past
    @events = Event.approved.past.not_deleted
  end

  def show
    if @event.unapproved && @event.organizer_id != current_user.id
      flash[:alert] = 'You are not allowed to access this event.'
      redirect_back(fallback_location: root_path)
    elsif @event.deleted
      flash[:alert] = 'This event has been deleted by the organizer.'
      redirect_back(fallback_location: root_path)
    end
  end

  def new
    if !current_user
      redirect_to sign_in_path, flash: { :info => "Please sign into your existing account or create a new one to submit events." }
    else
      @event = Event.new
      @event.tags.build
    end
  end

  def preview
    @event = Event.new(ApplicationProcess::Params.clean(event_params))

    if @event.valid?
      render :preview
    else
      render :new
    end
  end

  def create
    @event = Event.new(ApplicationProcess::Params.clean(event_params))
    @event.organizer_id = current_user.id

    if @event.save
      User.admin.each do |user|
        AdminMailer.submitted_event(@event, user.email).deliver_later
      end
      OrganizerMailer.submitted_event(@event).deliver_later
      redirect_to events_url, notice: "Thank you for submitting #{@event.name}. We will review it shortly."
    else
      render :new
    end
  end

  def edit
    if @event.uneditable_by?(current_user)
      redirect_to event_url(@event), alert: "Your event can't be edited, because the deadline has passed."
    end
  end

  def update
    if @event.uneditable_by?(current_user)
      head :forbidden
    elsif @event.update(event_params)
      url = current_user.admin? ? admin_url : user_url(current_user)

      redirect_to url, notice: "You have successfully updated #{@event.name}."
    else
      render :edit
    end
  end

  def destroy
    @event.skip_validation = true
    delete_event_data
    delete_event_applications_data
    redirect_to user_path(current_user)
  end

  private
    def get_event
      @event = Event.find(params[:id])
    end

    def event_params
      if current_user.admin?
        admin_event_params
      else
        organizer_event_params
      end
    end

    def organizer_event_params
      params.require(:event).permit permitted_params_for_event_organizers
    end

    def admin_event_params
      params.require(:event).permit(
        permitted_params_for_event_organizers + [:approved]
      )
    end

    def permitted_params_for_event_organizers
      [
        :organizer_name, :organizer_email, :organizer_email_confirmation,
        :description, :name, :logo, :start_date, :end_date, :ticket_funded,
        :accommodation_funded, :travel_funded, :deadline, :number_of_tickets,
        :website, :code_of_conduct, :city, :country, :applicant_directions,
        :data_protection_confirmation, :application_link, :application_process,
        :twitter_handle, :state_province,
        { :tag_ids => [] }, tags_attributes: [:id, :name, :category_id]
      ]
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end

    def delete_event_data
      attributes = @event.attributes.keys - ["id", "created_at", "updated_at", "deleted", "country"]
      columns = {deleted: true}
      attributes.each do |attr|
        if @event[attr].class == TrueClass || @event[attr].class == FalseClass
          columns[attr] = false
        else
          columns[attr] = nil
        end
      end
      @event.update_attributes(columns)
    end

    def delete_event_applications_data
      attributes = @event.applications.attributes.keys - ["id", "event_id", "created_at", "updated_at", "submitted", "deleted"]
      columns = {deleted: true}
      attributes.each do |attr|
        if @event.applications[attr].class == TrueClass || @event.applications[attr].class == FalseClass
          columns[attr] = false
        else
          columns[attr] = nil
        end
      end
      @event.applications.update_attributes(columns)
    end
end
