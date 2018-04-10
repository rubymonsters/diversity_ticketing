require 'test_helper'

class ApplicantMailerTest < ActionMailer::TestCase
  def setup
    @event = make_event
    @application = make_application(@event)
  end

  test "application_received" do
    email = ApplicantMailer.application_received(@application)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@application.email], email.to
    assert_equal "Your application for #{@application.event.name}.", email.subject
  end
end
