module EventsHelper

  def event_image(event)
    if event.logo != ''
      image_tag event.logo
    else
      image_tag "event-default"
    end
  end
    
end
