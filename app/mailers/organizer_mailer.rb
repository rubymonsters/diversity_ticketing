class OrganizerMailer < ApplicationMailer
  def submitted_event(event)
    @event = event
    mail(to: @event.organizer_email, subject: 'You submitted a new event.')
  end

  def approved_event(event)
    @event = event
    mail(
      to: @event.organizer_email,
      subject: "Your event #{event.name} has been approved.",
      template_path: 'organizer_mailer/approved_event',
      template_name: @event.application_process,
    )
  end

  def ticket_capacity_reached(event)
    @event = event
    mail(
      to: @event.organizer_email,
      subject: "Your event #{@event.name} received more applications than available tickets.",
    )
  end

  def passed_event_deadline(event)
    @event = event
    mail(to: @event.organizer_email, subject: "#{@event.name}'s deadline passed.")
  end
end
