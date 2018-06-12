class UserNotificationsMailer < ApplicationMailer
  def new_local_event(event, user)
    @event = event
    @user = user
    mail(to: @user.email, subject: 'A new event in your country!')
  end
end
