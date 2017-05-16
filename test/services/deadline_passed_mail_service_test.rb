require 'test_helper'

class DeadlinePassedMailServiceTest < ActiveSupport::TestCase
  describe "sending emails about events with passed deadlines to admins"  do
    it "send emails about right events to the right people" do
      make_event(deadline: 1.days.ago, name: "Valid Event")
      make_event(deadline: 1.week.ago)
      make_user(email: "bad@example.com")
      make_admin(email: "good@example.com")

      ActionMailer::Base.deliveries.clear

      DeadlinePassedMailService.send_deadline_passed_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.length
      mail = mails.first
      assert_equal ["good@example.com"], mail.to
      assert mail.subject =~ /Valid Event/
    end
  end
end
