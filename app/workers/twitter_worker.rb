class TwitterWorker
  include Sidekiq::Worker
  extend ApplicationHelper

  def self.announce_event(event)
    event_url = routes.event_url(event)
    perform_async(event.name, format_date(event.deadline), event_url, event.twitter_handle)
    Tweet.create(event_id: event.id, published: true)
  end

  def self.routes
    @routes ||= Class.new {
      include Rails.application.routes.url_helpers

      def default_url_options
        Rails.configuration.x.worker_routes.default_url_options
      end
    }.new
  end

  def perform(event_name, event_deadline, event_url, twitter_handle, event_tickets)
    name_or_handle = (twitter_handle ? "@#{twitter_handle}" : "#{event_name.truncate(30, separator: ' ')}")
    message = ["So awesome! #{name_or_handle} is giving away #{event_tickets} #DiversityTickets — you can apply for them here: #{event_url} ",
    "We have #{event_tickets} #DiversityTickets for #{name_or_handle} — apply by #{event_deadline} here: #{event_url}",
    "Hooray, #{name_or_handle} are offering #DiversityTickets for their event! Apply for them before #{event_deadline}: #{event_url}"]

    TWITTER_CLIENT.update(message.sample)
  end
end
