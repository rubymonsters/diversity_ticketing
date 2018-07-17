class PastEventDateService
  # Looks for all events in the past week to overwrite applications for security
  # just in case the task does not always run properly:
  def self.delete_application_data_after_event
    events = Event.approved.where('end_date < ? AND end_date > ?', Time.zone.now, 1.week.ago)
    events.map { |e| e.delete_application_data }
  end

  def self.delete_all_past_events_application_data
    events = Event.approved.past
    events.map { |e| e.delete_application_data }
  end
end
