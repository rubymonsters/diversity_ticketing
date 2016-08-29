class TwitterWorker
  include Sidekiq::Worker

  def self.announce_event(event)
    event_url = routes.event_url(event)
    perform_async(event.name, event.deadline, event_url)
  end

  def self.routes
    @routes ||= Class.new {
      include Rails.application.routes.url_helpers

      def default_url_options
        Rails.configuration.x.worker_routes.default_url_options
      end
    }.new
  end

  def perform(event_name, event_deadline, event_url)
    TWITTER_CLIENT.update("So great! #{event_name} is offering free diversity tickets! Apply until #{event_deadline} at #{event_url}!")
  end
end
