namespace :events do
  namespace :past_events do
    desc "Deletes personal data from all event applications the day after an event took place"
    task :delete_data => :environment do
      puts "Deletes applications data..."
      PastEventDateService.delete_application_data_after_event
      puts "Deleted."
    end
  end
end
