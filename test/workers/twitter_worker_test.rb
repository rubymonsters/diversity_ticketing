require 'test_helper'

class TwitterWorkerTest < ActiveSupport::TestCase
  include ApplicationHelper

  it 'sends a tweet with name if event has no twitter handle' do
    event = make_event(
      name: 'Awesome Event',
      id: 101,
      deadline: 2.weeks.from_now
    )

    event.reload

    TWITTER_CLIENT.expects(:update).once

    TwitterWorker.announce_event(event)
  end

  it 'sends a tweet with twitter handle if event has a twitter handle' do
    event = make_event(
      name: 'Awesome Event',
      id: 101,
      deadline: 2.weeks.from_now,
      twitter_handle: 'awesome_event'
    )

    event.reload

    TWITTER_CLIENT.expects(:update).once

    TwitterWorker.announce_event(event)
  end

  it 'uses shortened name if name is longer than 30 characters' do
     event = make_event(
      name: 'Super Duper Mega Crazy Awesome Event',
      id: 101,
      deadline: 2.weeks.from_now
    )

    event.reload

    TWITTER_CLIENT.expects(:update).once

    TwitterWorker.announce_event(event)
  end
end
