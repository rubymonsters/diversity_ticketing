class TwitterWorker
  include Sidekiq::Worker
  extend ApplicationHelper

  def self.announce_event(event)
    event_url = routes.event_url(event)
    perform_async(event.name, format_date(event.deadline), event_url, event.twitter_handle)
    Tweet.create(event_id: event.id)
  end

  def self.routes
    @routes ||= Class.new {
      include Rails.application.routes.url_helpers

      def default_url_options
        Rails.configuration.x.worker_routes.default_url_options
      end
    }.new
  end

  def perform(event_name, event_deadline, event_url, twitter_handle)
    message = ["So great!"]
    message << (twitter_handle ? "@#{twitter_handle}" : event_name.truncate(30, separator: ' '))
    message << "is offering free diversity tickets! Apply before #{event_deadline} at #{event_url}!"

    TWITTER_CLIENT.update(message.join(' '))
  end
end
