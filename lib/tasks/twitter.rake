namespace :twitter do
  namespace :announce do
    desc "Tweets the next approved event"
    task :event_approved => :environment do
      puts "Tweeting..."
      EventTweetService.tweet_approved_event
      puts "Done."
    end
  end
end
