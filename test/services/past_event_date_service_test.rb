require 'test_helper'

class PastEventDateServiceTest < ActiveSupport::TestCase
  describe 'deletes application data for events that took place yesterday'  do
    it 'overwrites correct applications' do
      past_event = make_event(approved: true, name: 'Yesterdays Event')
      old_past_event = make_event(approved: true, name: 'Old Event')
      future_event = make_event(approved: true, end_date: 1.week.from_now)
      user = make_user(email: 'user@example.com')
      past_application = make_application(
        past_event,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )
      old_past_application = make_application(
        old_past_event,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )
      future_application = make_application(
        future_event,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )

      past_event.update_attributes(start_date: Time.now.yesterday, end_date: Time.now.yesterday)
      old_past_event.update_attributes(start_date: 2.weeks.ago, end_date: 2.weeks.ago)

      assert_equal 'user@example.com', future_application.email
      assert_equal 'user@example.com', past_application.email
      assert_equal 'user@example.com', old_past_application.email

      PastEventDateService.delete_application_data_after_event

      future_application.reload
      old_past_application.reload
      past_application.reload

      assert_equal 'user@example.com', future_application.email
      assert_equal 'user@example.com', old_past_application.email
      assert_nil past_application.email
    end

    it 'overwrites correct drafts' do
      past_event = make_event(approved: true, name: 'Yesterdays Event')
      future_event = make_event(approved: true, end_date: 1.week.from_now)
      user = make_user(email: 'user@example.com')
      past_draft = make_draft(
        past_event,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )
      future_draft = make_draft(
        future_event,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )

      past_event.update_attributes(start_date: Time.now.yesterday, end_date: Time.now.yesterday)

      assert_equal 'user@example.com', future_draft.email
      assert_equal 'user@example.com', past_draft.email

      PastEventDateService.delete_application_data_after_event

      future_draft.reload
      past_draft.reload

      assert_equal 'user@example.com', future_draft.email
      assert_nil past_draft.email
    end
  end

  describe 'deletes application data for all past events'  do
    it 'covers correct deletion of all applications of past events' do
      past_event_1 = make_event(approved: true, name: 'Yesterdays Event')
      past_event_2 = make_event(approved: true, name: 'Old Event')
      past_event_3 = make_event(approved: true, name: 'Older Event')
      future_event = make_event(approved: true, end_date: 1.week.from_now)
      user = make_user(email: 'user@example.com')
      past_application_1 = make_application(
        past_event_1,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )
      past_application_2 = make_draft(
        past_event_2,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )
      past_application_3 = make_application(
        past_event_3,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )
      future_application = make_application(
        future_event,
        applicant_id: user.id,
        email: user.email,
        email_confirmation: user.email
      )

      past_event_1.update_attributes(start_date: Time.now.yesterday, end_date: Time.now.yesterday)
      past_event_2.update_attributes(start_date: 2.weeks.ago, end_date: 2.weeks.ago)
      past_event_3.update_attributes(start_date: 1.year.ago, end_date: 1.year.ago)

      assert_equal 3, Event.approved.past.count
      assert_equal 3, Event.approved.past.map { |e| e.applications.count }.inject { |sum,n| sum += n }
      assert_equal 'user@example.com', past_application_1.email
      assert_equal 'user@example.com', past_application_2.email
      assert_equal 'user@example.com', past_application_3.email
      assert_equal 'user@example.com', future_application.email


      PastEventDateService.delete_all_past_events_application_data

      past_application_1.reload
      past_application_2.reload
      past_application_3.reload

      assert_nil past_application_1.email
      assert_nil past_application_2.email
      assert_nil past_application_3.email
      assert_equal 'user@example.com', future_application.email
    end
  end
end
