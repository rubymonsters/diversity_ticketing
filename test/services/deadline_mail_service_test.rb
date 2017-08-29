require 'test_helper'

class DeadlineMailServiceTest < ActiveSupport::TestCase
  describe "sending emails about events with upcoming deadlines to admins"  do
    it "send emails about right events to the right people" do
      make_event(deadline: 2.days.from_now, approved: true, name: "Valid Event")
      make_event(deadline: 1.week.from_now)
      make_user(email: "bad@example.com")
      make_admin(email: "good@example.com")

      ActionMailer::Base.deliveries.clear

      DeadlineMailService.send_deadline_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.length
      mail = mails.first
      assert_equal ["good@example.com"], mail.to
      assert mail.subject =~ /Valid Event/
    end

    it "excludes events that are not approved" do
      make_event(deadline: 2.days.from_now, approved: true, name: "Valid Event")
      make_event(deadline: 2.days.from_now, approved: false, name: "Unapproved Event")
      make_admin

      ActionMailer::Base.deliveries.clear

      DeadlineMailService.send_deadline_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.length
      assert mails.first.subject =~ /Valid Event/
    end
  end
end
