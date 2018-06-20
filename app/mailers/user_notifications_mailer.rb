class UserNotificationsMailer < ApplicationMailer
  def new_local_event(event, user)
    @event = event
    @user = user
    mail(to: @user.email, subject: 'A new event in your country!')
  end

  def new_field_specific_event(event, user)
    @event = event
    @user = user
    mail(to: @user.email, subject: 'A new event of your interest!')
  end
end
