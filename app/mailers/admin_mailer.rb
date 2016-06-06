class AdminMailer < ApplicationMailer
  def submitted_event(event, email)
    @event = event
    mail(to: email, subject: 'A new event has been submitted.')
  end
end
