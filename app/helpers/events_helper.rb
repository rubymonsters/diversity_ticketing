module EventsHelper

  def event_image(event)
    if event.logo && event.logo != ''
      image_tag event.logo
    else
      image_tag "event-default.png"
    end
  end

  def breadcrumb_link_according_to_user_status
    if current_user && current_user.admin?
      link_to 'Admin', admin_path
    else
      link_to 'Events', events_path
    end
  end
end
