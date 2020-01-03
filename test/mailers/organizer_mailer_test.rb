require 'test_helper'

class OrganizerMailerTest < ActionMailer::TestCase
  test "submitted_event" do
    event = make_event
    email = OrganizerMailer.submitted_event(event)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [event.organizer_email], email.to
    assert_equal 'You submitted a new event.', email.subject
  end

  test "approved_event for event with `selection_by_travis`" do
    event = make_event(application_process: 'selection_by_travis')
    email = OrganizerMailer.approved_event(event)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [event.organizer_email], email.to
    assert_equal "Your event #{event.name} has been approved.", email.subject
    assert /You chose the option to have us handle both the application and the selection process/ =~ email.body.raw_source
  end

  test "approved_event for event with `selection_by_organizer`" do
    event = make_event(application_process: 'selection_by_organizer')
    email = OrganizerMailer.approved_event(event)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [event.organizer_email], email.to
    assert_equal "Your event #{event.name} has been approved.", email.subject
    assert /You chose the option to have us handle the application and handle the selection process yourself/ =~ email.body.raw_source
  end

  test "approved_event for event with `application_by_organizer`" do
    event = make_event(application_process: 'application_by_organizer', application_link: 'https://mylink.com')
    email = OrganizerMailer.approved_event(event)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [event.organizer_email], email.to
    assert_equal "Your event #{event.name} has been approved.", email.subject
    assert /You have selected the option of just listing your event on our site/ =~ email.body.raw_source
  end

  test "passed_event_deadline" do
    event = make_event
    email = OrganizerMailer.passed_event_deadline(event)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [event.organizer_email], email.to
    assert_equal "#{event.name}'s deadline passed.", email.subject
  end
end
