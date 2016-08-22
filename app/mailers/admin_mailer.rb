class AdminMailer < ApplicationMailer
  def submitted_event(event, email)
    @event = event
    mail(to: email, subject: 'A new event has been submitted.')
  end

  def upcoming_event_deadline
    @event = event
    mail(to: email, subject: 'Event deadline in two days.')
    
  end
end
