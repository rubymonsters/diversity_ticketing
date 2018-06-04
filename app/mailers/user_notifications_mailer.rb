class UserNotificationsMailer < ApplicationMailer
  def submitted_event(event, user)
    @event = event
    @user = user
    mail(to: @user.email, subject: 'A new event in your country!')
  end
end
