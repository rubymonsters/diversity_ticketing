class TwitterWorker
  include Sidekiq::Worker
  include ApplicationHelper

  def self.announce_event(event)
    event_url = routes.event_url(event)
    perform_async(event.name, event.deadline, event_url, event.twitter_handle)
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
    message = "So great! #{event_name}"
    message.concat(" (#{twitter_handle})") if twitter_handle
    message.concat(" is offering free diversity tickets! Apply until #{format_date(event_deadline)} at #{event_url}!")

    TWITTER_CLIENT.update(message)
  end
end
