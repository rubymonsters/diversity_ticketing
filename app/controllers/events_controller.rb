class EventsController < ApplicationController
  before_action :set_s3_direct_post, only: [:new, :preview, :edit, :create, :update]
  before_action :get_event, only: [:show, :edit, :update, :destroy, :delete_event_data, :delete_event_applications_data]
  before_action :set_approved_tickets_count, only: [:show]
  skip_before_action :require_login, only: [:index, :index_past, :show, :destroy]
  before_action :open_events, :closed_events, :past_events, :selected_tags, only: [:index]

  def index_past
    @events = EventSearchService.new(params).results.approved.past.active.order(end_date: :desc)
    @selected_tags = EventSearchService.new(params).selected_tags
  end

  def show
    if @event.unapproved && @event.organizer_id != current_user.id
      flash[:alert] = t('.not_allowed')
      redirect_back(fallback_location: root_path)
    elsif @event.deleted
      flash[:alert] = t('.event_deleted')
      redirect_back(fallback_location: root_path)
    end
  end

  def new
    @event = Event.new
    @event.tags.build
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
      redirect_to events_url, notice: t('.thank_you', event_name: @event.name)
    else
      render :new
    end
  end

  def edit
    if @event.uneditable_by?(current_user)
      redirect_to event_url(@event), alert: t('.deadline_passed')
    end
  end

  def update
    if @event.uneditable_by?(current_user)
      head :forbidden
    elsif @event.update(event_params)
      redirect_back fallback_location: '/', notice: t('.update_success', event_name: @event.name)
    else
      render :edit
    end
  end

  def destroy
    if @event.deletable_by?(current_user) && @event.past?
      @event.skip_validation = true
      delete_event_data
      unless @event.applications.count == 0
        @event.delete_application_data
      end
      redirect_to user_path(current_user)
    else
      head :forbidden
    end
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
        :twitter_handle, :state_province, :approved_tickets, :locale,
        { :tag_ids => [] }, tags_attributes: [:id, :name, :category_id]
      ]
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end

    def delete_event_data
      attributes = @event.attributes.keys - ["id", "created_at", "updated_at", "deleted", "start_date", "end_date", "country", "application_process", "number_of_tickets", "approved_tickets", "approved"]
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

    def set_approved_tickets_count
      if @event.approved_tickets == 0
        approved_tickets = @event.applications.where(status: 'approved').count
        @event.update_attributes(approved_tickets: approved_tickets)
      end
    end

    def open_events
      @open_events = EventSearchService.new(params).results.approved.upcoming.open.order(:deadline)
    end

    def closed_events
      @closed_events = EventSearchService.new(params).results.approved.upcoming.closed.order(:deadline)
    end

    def past_events
      @past_events = Event.approved.past.active
    end

    def selected_tags
      @selected_tags = EventSearchService.new(params).selected_tags
    end
end
