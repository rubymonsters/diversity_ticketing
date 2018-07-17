namespace :events do
  namespace :past_events do
    desc "Deletes personal data from all event applications for events that took place during the last week"
    task :delete_data => :environment do
      puts "Deletes applications data..."
      PastEventDateService.delete_application_data_after_event
      puts "Deleted."
    end
  end

  namespace :all_past_events do
    desc "Deletes personal data from all event applications of past events"
    task :delete_all_data => :environment do
      puts "Deletes all past applications data..."
      PastEventDateService.delete_all_past_events_application_data
      puts "All done."
    end
  end
end
