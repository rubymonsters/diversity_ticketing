namespace :admin do
  namespace :mail do
    task :upcoming_deadline => :environment do
      puts "Sending emails for upcoming deadlines to admins."
      DeadlineMailService.send_deadline_mail
      puts "Done."
    end
  end
end
