require 'test_helper'

class TwitterWorkerTest < ActiveSupport::TestCase
  include ApplicationHelper

  test 'it sends a tweet correctly' do
    event = Event.new(name: "Awesome Event", id: 101, deadline: 2.weeks.from_now)
    TWITTER_CLIENT.expects(:update).with("So great! Awesome Event is offering free diversity tickets! Apply until #{format_date(2.weeks.from_now.to_date.to_s)} at https://test.host/events/101!").once
    TwitterWorker.announce_event(event)
  end

  test 'it sends a tweet with event twitter handle' do
    event = Event.new(name: "Awesome Event", id: 101, deadline: 2.weeks.from_now, twitter_handle: "@awesome_event")
    TWITTER_CLIENT.expects(:update).with("So great! Awesome Event (@awesome_event) is offering free diversity tickets! Apply until #{format_date(2.weeks.from_now.to_date)} at https://test.host/events/101!").once
    TwitterWorker.announce_event(event)
  end
end
