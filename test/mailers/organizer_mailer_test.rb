require 'test_helper'

class OrganizerMailerTest < ActionMailer::TestCase
  def setup
    @event = make_event
  end

  test "submitted_event" do
    # Create the email and store it for further assertions
    email = OrganizerMailer.submitted_event(@event)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@event.organizer_email], email.to
    assert_equal 'You submitted a new event.', email.subject
  end

  test "approved_event" do
    # Create the email and store it for further assertions
    email = OrganizerMailer.approved_event(@event)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@event.organizer_email], email.to
    assert_equal 'Your event has been approved.', email.subject
  end
end
