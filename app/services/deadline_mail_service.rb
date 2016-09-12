class DeadlineMailService
  def self.send_deadline_mail
    Event.upcoming_deadline.each do |event| 
      User.admin.each do |user|
        AdminMailer.upcoming_event_deadline(event, user.email).deliver_later
      end
    end
  end
end