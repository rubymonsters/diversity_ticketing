namespace :admin do
  namespace :mail do
    desc "Send emails for upcoming deadlines to admins"
    task :upcoming_deadline => :environment do
      puts "Sending emails for upcoming deadlines to admins."
      DeadlineMailService.send_deadline_mail
      puts "Done."
    end

    desc "Send emails for passed deadlines to admins"
    task :passed_deadline => :environment do
      puts "Sending emails for passed deadlines to admins."
      DeadlinePassedMailService.send_deadline_passed_mail
      puts "Done."
    end
  end

 
  namespace :categories do
    desc "create categories"
    task :create => :environment do
      CreateCategoriesService.create_categories
    end
  end
end

