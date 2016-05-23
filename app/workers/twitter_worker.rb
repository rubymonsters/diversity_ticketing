class TwitterWorker
  include Sidekiq::Worker
  def perform(event_name, event_url)
  	TWITTER_CLIENT.update("#{event_name} is a new event on #{event_url}!
  		Check it out :)")
  end
end