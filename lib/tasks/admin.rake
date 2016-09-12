namespace :admin do
  namespace :mail do
    task :upcoming_deadline => :environment do
      DeadlineMailService.send_deadline_mail
    end
  end
end