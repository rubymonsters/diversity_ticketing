require 'test_helper'

class ApplicantMailerTest < ActionMailer::TestCase
  def setup
    @event = make_event
    @draft = make_application(@event, submitted: false)
  end

  test "application_received" do
    @application = make_application(@event)
    email = ApplicantMailer.application_received(@application)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@application.email], email.to
    assert_equal "Your application for #{@application.event.name}.", email.subject
  end

  test "deadline_reminder sent" do
    @event.update_attributes(deadline: 2.days.from_now)
    email = ApplicantMailer.deadline_reminder(@draft)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@draft.email], email.to
    assert_equal "#{@draft.event.name} deadline in two days.", email.subject
  end
end
