class AdminMailer < ApplicationMailer
  def submitted_event(event, email)
    @event = event
    mail(to: email, subject: 'A new event has been submitted.')
  end

  def upcoming_event_deadline(event, email)
    @event = event
    mail(to: email, subject: "#{@event.name} deadline in two days.")
  end

  def passed_event_deadline(event, email)
    @event = event
    mail(to: email, subject: "#{@event.name} deadline yesterday.")
  end
end
