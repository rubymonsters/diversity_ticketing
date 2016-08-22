namespace :admin do
  namespace :mail do
    task :upcoming_deadline => :environment do
      Event.upcoming_deadline.each do |event| 
        # parse over all admin email adresses
      end
    end
  end
end