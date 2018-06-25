class PastEventDateService
  def self.delete_application_data_after_event
    Event.approved.where(end_date: Time.zone.yesterday).delete_application_data
  end
end
