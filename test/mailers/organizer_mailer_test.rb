require 'test_helper'

class OrganizerMailerTest < ActionMailer::TestCase
  def setup
    @event = make_event
  end

  test "submitted_event" do
    email = OrganizerMailer.submitted_event(@event)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@event.organizer_email], email.to
    assert_equal 'You submitted a new event.', email.subject
  end

  test "approved_event" do
    email = OrganizerMailer.approved_event(@event)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@event.organizer_email], email.to
    assert_equal 'Your event has been approved.', email.subject
  end
end
