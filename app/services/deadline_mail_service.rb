class DeadlineMailService
  def self.send_deadline_mail
    Event.approved.deadline_in_two_days.each do |event|
      User.admin.each do |user|
        AdminMailer.upcoming_event_deadline(event, user.email).deliver_later
      end
    end
  end

  def self.send_deadline_reminder_applicants
    Event.approved.deadline_in_two_days.each do |event|
      event.applications.where(submitted: false).each do |application|
        ApplicantMailer.deadline_reminder(application).deliver_later
      end
    end
  end
end
