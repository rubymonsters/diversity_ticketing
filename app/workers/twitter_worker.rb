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
    message_start = ["So great!","Hooray!","Amazing news!","Nice!!"]
    message_end =
    [
      "is offering free diversity tickets! Apply before #{event_deadline} at #{event_url}!",
      "just made free diversity tickets available! You can apply for them at #{event_url} until #{event_deadline}.",
      "lets you apply for free diversity tickets! Submit your application before #{event_deadline} at #{event_url}!",
      "has free diversity tickets available! Make sure to apply for them before #{event_deadline} here: #{event_url}!"
    ]
    message = [message_start.sample]
    message << (twitter_handle ? "@#{twitter_handle}" : event_name.truncate(30, separator: ' '))
    message << [message_end.sample]

    TWITTER_CLIENT.update(message.join(' '))
  end
end
