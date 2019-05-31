module EventsHelper

  def event_image(event)
    if event.logo && event.logo != ''
      image_tag event.logo, skip_pipeline: true
    else
      image_tag "event-default.png"
    end
  end

  #Used in events/edit and events/show:

  def breadcrumb_locals_according_to_user_status
    if current_user && @event.organizer_id == current_user.id
      { your_events: t('.your_events') }
    elsif current_user && current_user.admin?
      { admin: t('.admin_link') }
    else
      { events: t('.events_link') }
    end
  end

end
