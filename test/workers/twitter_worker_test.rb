require 'test_helper'

class TwitterWorkerTest < ActiveSupport::TestCase

	test 'it sends a tweet correctly' do
		event = Event.new(name: "Awesome Event", id: 101)
		TWITTER_CLIENT.expects(:update).with("Awesome Event is a new event on https://test.host/events/101 ! Check it out :)").once

		TwitterWorker.announce_event(event)
	end
end