require 'test_helper'

class DeadlineMailServiceTest < ActiveSupport::TestCase
  describe 'sending emails about events with upcoming deadlines to admins'  do
    it 'send emails about right events to the right people' do
      make_event(deadline: 2.days.from_now, approved: true, name: 'Valid Event')
      make_event(deadline: 1.week.from_now)
      make_user(email: 'bad@example.com')
      make_admin(email: 'good@example.com')

      ActionMailer::Base.deliveries.clear

      DeadlineMailService.send_deadline_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.length
      mail = mails.first
      assert_equal ['good@example.com'], mail.to
      assert mail.subject =~ /Valid Event/
    end

    it 'excludes events that are not approved' do
      make_event(deadline: 2.days.from_now, approved: true, name: 'Valid Event')
      make_event(deadline: 2.days.from_now, approved: false, name: 'Unapproved Event')
      make_admin

      ActionMailer::Base.deliveries.clear

      DeadlineMailService.send_deadline_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.length
      assert mails.first.subject =~ /Valid Event/
    end
  end

  describe 'sending emails to applicants about upcoming deadlines for their application drafts'  do
    it 'send emails about right events to the right people' do
      event = make_event(deadline: 2.days.from_now, approved: true, name: 'Valid Event')
      late_event = make_event(deadline: 1.week.from_now, approved: true, name: 'Late Event')
      make_admin(email: 'bad@example.com')
      user = make_user(email: 'joe@test.com')
      draft = make_draft(event, applicant_id: user.id)
      late_draft = make_draft(late_event, applicant_id: user.id)

      ActionMailer::Base.deliveries.clear

      DeadlineMailService.send_deadline_reminder_applicants

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.length
      mail = mails.first
      assert_equal [user.email], mail.to
      assert mail.subject =~ /Valid Event/
    end

    it 'excludes reminders for applications that have been submitted' do
      event = make_event(deadline: 2.days.from_now, approved: true, name: 'Draft Event')
      event2 = make_event(deadline: 2.days.from_now, approved: true, name: 'Application Event')
      user = make_user(email: 'joe@test.com')
      make_draft(event, applicant_id: user.id)
      make_application(event2, applicant_id: user.id)

      ActionMailer::Base.deliveries.clear

      DeadlineMailService.send_deadline_reminder_applicants

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.length
      assert mails.first.subject =~ /Draft Event/
    end
  end
end
