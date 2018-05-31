require 'test_helper'

class EventTweetServiceTest < ActiveSupport::TestCase
  describe 'tweets about upcoming open events'  do
    it 'if they are approved' do
      event = make_event(deadline: 2.days.from_now, approved: true, name: 'Valid Event')

      TWITTER_CLIENT.expects(:update)

      EventTweetService.tweet_approved_event

      assert_equal Tweet.last.event_id, event.id
    end
  end

  describe 'does not tweets about upcoming open events'  do
    it 'if they have already been tweeted' do
      announced_event = make_event(deadline: 2.days.from_now, approved: true, name: 'Announced Event')
      event = make_event(deadline: 2.days.from_now, approved: true, name: 'Not Announced Event')
      Tweet.create(event_id: announced_event.id)

      TWITTER_CLIENT.expects(:update)

      EventTweetService.tweet_approved_event

      assert_equal Tweet.last.event_id, event.id
    end

    it 'if they are not approved events' do
      event = make_event(deadline: 2.days.from_now, approved: false, name: 'Invalid Event')

      EventTweetService.tweet_approved_event

      assert_nil Tweet.last
    end
  end
  
end
