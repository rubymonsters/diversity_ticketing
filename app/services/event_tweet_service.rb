class EventTweetService
  def self.tweet_approved_event
    events = Event.open.approved.order("deadline ASC").ids
    do_not_publish = Tweet.all.pluck(:event_id)
    remaining_events = events - do_not_publish

    return if remaining_events.empty?

    event_to_announce = Event.find(remaining_events[0])
    TwitterWorker.announce_event(event_to_announce)
  end
end
