class TwitterWorker
  include Sidekiq::Worker
  extend ApplicationHelper

  def self.announce_event(event)
    perform_async(event)
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

  def perform(event)
    deadline = format_date(event.deadline)
    event_url = routes.event_url(event)
    name_or_handle = (event.twitter_handle ? "@#{event.twitter_handle}" : "#{event.name.truncate(30, separator: ' ')}")
    message = ["So awesome! #{name_or_handle} is giving away #{event.number_of_tickets} #DiversityTickets — you can apply for them here: #{event_url} ",
    "Are you from an underrepresented group and interested in #[TAG]? We have #{event.number_of_tickets} #DiversityTickets for #{name_or_handle} — apply by #{deadline} here: #{event_url}",
    "Hooray, #{name_or_handle} are offering #DiversityTickets for their event! Apply for them before #{deadline}: #{event_url}"]

    TWITTER_CLIENT.update(message.sample)
  end
end
