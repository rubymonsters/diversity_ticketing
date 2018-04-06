require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase
  def setup
    @event = make_event
    @email = 'test@admin.com'
  end

  test "submitted_event" do
    # Create the email and store it for further assertions
    email = AdminMailer.submitted_event(@event, @email)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@email], email.to
    assert_equal 'A new event has been submitted.', email.subject
  end

  test "upcoming_event_deadline" do
    # Create the email and store it for further assertions
    email = AdminMailer.upcoming_event_deadline(@event, @email)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@email], email.to
    assert_equal "#{@event.name} deadline in two days.", email.subject
  end

  test "passed_event_deadline" do
    # Create the email and store it for further assertions
    email = AdminMailer.passed_event_deadline(@event, @email)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@email], email.to
    assert_equal "#{@event.name} deadline yesterday.", email.subject
  end
end
