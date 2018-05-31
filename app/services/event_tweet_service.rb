class EventTweetService
  def self.tweet_approved_event
    remaining_events = Event.open.approved
    return if remaining_events.empty?

    if Tweet.last
      return if Tweet.last.event_id == remaining_events.last.id
      last_tweet = Event.find_by(id: Tweet.last.event_id)
      event_index = remaining_events.index(last_tweet) + 1
    else
      event_index = 0
    end

    TwitterWorker.announce_event(remaining_events[event_index])
  end
end
