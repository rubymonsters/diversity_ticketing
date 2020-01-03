require 'test_helper'

class DeadlinePassedMailServiceTest < ActiveSupport::TestCase
  describe 'sending emails about events with passed deadlines to admins and organizer' do
    it 'sends emails to organizer & admin when application process is `selection_by_organizer`' do
      organizer = make_user(email: 'organizer@example.com')
      make_event(
        deadline: 1.days.ago, approved: true, name: 'Valid Event', organizer_id: organizer.id,
        organizer_email: organizer.email, organizer_email_confirmation: organizer.email,
        application_process: 'selection_by_organizer',
      )
      make_user(email: 'user@example.com')
      admin = make_admin(email: 'admin@example.com')

      ActionMailer::Base.deliveries.clear

      DeadlinePassedMailService.send_deadline_passed_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 2, mails.length

      admin_mails = mails.select { |mail| mail.to == [admin.email] }
      organizer_mails = mails.select { |mail| mail.to == [organizer.email] }
      assert_equal 1, admin_mails.length
      assert_equal 1, organizer_mails.length
    end

    it 'sends email only to admin when application process is `selection_by_travis`' do
      organizer = make_user(email: 'organizer@example.com')
      make_event(
        deadline: 1.days.ago, approved: true, name: 'Valid Event', organizer_id: organizer.id,
        organizer_email: organizer.email, organizer_email_confirmation: organizer.email,
        application_process: 'selection_by_travis',
      )
      make_user(email: 'user@example.com')
      admin = make_admin(email: 'admin@example.com')

      ActionMailer::Base.deliveries.clear

      DeadlinePassedMailService.send_deadline_passed_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 1, mails.length

      admin_mails = mails.select { |mail| mail.to == [admin.email] }
      organizer_mails = mails.select { |mail| mail.to == [organizer.email] }
      assert_equal 1, admin_mails.length
      assert_equal 0, organizer_mails.length
    end

    it 'excludes events that have the wrong deadline' do
      make_event(
        deadline: 1.week.ago, approved: true, name: 'Past Event',
        application_process: 'selection_by_organizer'
      )
      make_event(
        deadline: Date.tomorrow, approved: true, name: 'Future Event',
        application_process: 'selection_by_organizer'
      )
      make_admin

      ActionMailer::Base.deliveries.clear

      DeadlinePassedMailService.send_deadline_passed_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 0, mails.length
    end

    it 'excludes events that are listings (applications & selection are handled by organizer)' do
      make_event(
        deadline: 1.days.ago, approved: true, name: 'Listed Event',
        application_process: 'application_by_organizer', application_link: 'https://myconf.com'
      )
      make_admin

      ActionMailer::Base.deliveries.clear

      DeadlinePassedMailService.send_deadline_passed_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 0, mails.length
    end

    it 'excludes events that are not approved' do
      make_event(
        deadline: 1.days.ago, approved: false, name: 'Unapproved Event',
        application_process: 'selection_by_organizer'
      )
      make_admin

      ActionMailer::Base.deliveries.clear

      DeadlinePassedMailService.send_deadline_passed_mail

      mails = ActionMailer::Base.deliveries
      assert_equal 0, mails.length
    end
  end
end
