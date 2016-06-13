class TwitterWorker
  include Sidekiq::Worker

  def self.announce_event(event)
    event_url = routes.event_url(event)
    perform_async(event.name, event_url)
  end

  def self.routes
    @routes ||= Class.new {
      include Rails.application.routes.url_helpers

      def default_url_options
        Rails.configuration.x.worker_routes.default_url_options
      end
    }.new
  end

  def perform(event_name, event_url)
    TWITTER_CLIENT.update("#{event_name} is a new event on #{event_url} ! Check it out :)")
  end
end
