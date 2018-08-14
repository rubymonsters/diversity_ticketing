class OrganizerMailer < ApplicationMailer
  def submitted_event(event)
    @event = event
    mail(to: @event.organizer_email, subject: 'You submitted a new event.')
  end

  def approved_event(event)
    @event = event
    mail(to: @event.organizer_email, subject: 'Your event has been approved.')
  end

  def ticket_capacity_reached(event)
    @event = event
    mail(to: @event.organizer_email, subject: 'Your event received more applications than available tickets.')
  end
end
