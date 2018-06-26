class EventTweetService
  def self.tweet_approved_event
    events = Event.open.approved.order("deadline ASC").ids
    unpublished = Tweet.where(published: false).pluck(:event_id)
    remaining_events = events - unpublished

    return if remaining_events.empty?

    if Tweet.last
      return if Tweet.where(published: true).last == remaining_events.last
      last_tweet = Event.find_by(id: Tweet.where(published: true).last.event_id).id
      event_index = remaining_events.index(last_tweet) + 1
    else
      event_index = 0
    end
    event_to_announce = Event.find(remaining_events[event_index])
    TwitterWorker.announce_event(event_to_announce)
  end
end
