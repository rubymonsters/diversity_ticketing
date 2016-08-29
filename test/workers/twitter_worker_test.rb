require 'test_helper'

class TwitterWorkerTest < ActiveSupport::TestCase

  test 'it sends a tweet correctly' do
    event = Event.new(name: "Awesome Event", id: 101, deadline: 2.weeks.from_now)
    TWITTER_CLIENT.expects(:update).with("So great! Awesome Event is offering free diversity tickets! Apply until #{2.weeks.from_now.to_date} at https://test.host/events/101!").once
    TwitterWorker.announce_event(event)
  end
end
