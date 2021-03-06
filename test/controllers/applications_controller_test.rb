require 'test_helper'

class ApplicationsControllerTest < ActionController::TestCase
  describe '#new' do
    it 'adds a new application for the event' do
      event = make_event
      user = make_user
      sign_in_as(user)

      get :new, params: { event_id: event.id }

      assert_response :success
    end

    it 'proper redirects a non signed in user to continue_as_guest' do
      event = make_event

      get :new, params: { event_id: event.id }

      assert_redirected_to continue_as_guest_path
    end
  end

  describe '#create' do
    it 'proper redirects after successful application' do
      event = make_event

      post :create, params: {
        event_id: event.id,
        application: {
          attendee_info_1: 'some text',
          attendee_info_2: 'some text',
          name: 'Joe',
          email: 'joe@test.com',
          email_confirmation: 'joe@test.com',
          terms_and_conditions: '1',
          event: event
        },
        commit: 'Submit application'
      }

      assert_redirected_to event_path(event.id)
    end

    it 'does not redirect after failed validations' do
      event = make_event

      post :create, params: { event_id: event.id, application: { name: 'Joe' } }

      assert_response :success
    end

    it 'does not redirect when terms and conditions are not accepted' do
      event = make_event

      post :create, params: {
        event_id: event.id,
        application: {
          attendee_info_1: 'some text',
          attendee_info_2: 'some text',
          name: 'Joe',
          email: 'joe@test.com',
          email_confirmation: 'joe@test.com',
          terms_and_conditions: '0',
          event: event
        }
      }

      assert_response :success
    end

    it 'redirects to the event if the user already applied' do
      user = make_user
      event = make_event
      make_application(event, applicant_id: user.id)

      sign_in_as(user)

      post :create, params: { event_id: event.id, application:
        { applicant_id: user.id,
          attendee_info_1: 'some text',
          attendee_info_2: 'some text',
          name: user.name,
          email: user.email,
          email_confirmation: user.email,
          terms_and_conditions: '1',
          event: event }
        }

      assert_redirected_to event
      assert_equal "You have already applied for #{event.name}", flash[:alert]
    end
  end

  describe '#show' do
    it 'does not show application to visitors' do
      event = make_event
      application = make_application(event)

      get :show, params: { event_id: event.id, id: application.id }

      assert_redirected_to sign_in_path
    end

    it 'does not show application of other users' do
      user = make_user
      other_user = make_user(email: 'other@email.com')
      sign_in_as(user)

      event = make_event
      application = make_application(event, applicant_id: other_user.id)

      get :show, params: { event_id: event.id, id: application.id }

      assert_redirected_to root_path
    end

    it 'redirects users to applications overview if the event has been deleted' do
      user = make_user
      event = make_event(organizer_id: user.id)
      application = make_application(event, applicant_id: user.id)
      event.update_attributes(start_date: 1.week.ago, end_date: 1.week.ago, deadline: 10.days.ago)

      sign_in_as(user)

      get :show, params: { event_id: event.id, id: application.id }

      applications_controller = @controller

      @controller = EventsController.new
      delete :destroy, params: { id: event.id }

      @controller = applications_controller
      get :show, params: { event_id: event.id, id: application.id }

      assert_redirected_to user_applications_path(user.id)
      assert_equal(
        "You cannot view your application as the event you applied for has been removed from "\
        "Diversity Tickets",
        flash[:alert]
      )
    end
  end

  describe '#update' do
    it 'updates attributes of application' do
      user = make_user
      sign_in_as(user)
      event = make_event
      application = make_application(event, { applicant_id: user.id })

      post :update, params: {
        event_id: event.id,
        id: application.id,
        application: { name: "New Name",
          email: user.email,
          email_confirmation: user.email,
          terms_and_conditions: '1'
        }
      }

      application.reload

      assert_equal "New Name", application.name
    end

    it 'checks validations before the application is updated' do
      user = make_user
      sign_in_as(user)
      event = make_event
      application = make_application(event, { applicant_id: user.id })

      post :update, params: {
        event_id: event.id,
        id: application.id,
        application: { name: "New Name" }
      }

      application.reload

      assert_equal "Joe", application.name
    end
  end

  describe '#submit' do
    it 'submits an application if all their mandatory fields are present' do
      user = make_user
      sign_in_as(user)
      event = make_event
      application = make_draft(event, { applicant_id: user.id })

      post :submit, params: {
        event_id: event.id,
        id: application.id,
        application: {
          email: user.email,
          email_confirmation: user.email,
          terms_and_conditions: '1'
        }
      }

      application.reload

      assert_equal true, application.submitted
    end

    it 'does not submit application if mandatory fields are missing' do
      user = make_user
      sign_in_as(user)
      event = make_event
      application = make_draft(event, applicant_id: user.id)

      post :submit, params: {
        event_id: event.id,
        id: application.id,
        application: { applicant_id: user.id }
      }

      application.reload

      assert_equal false, application.submitted
    end

    it 'sends an email to the organizer if they have decided that want to get
    informed when the event reached the maximum number of applications' do
      organizer = make_user(capacity_email_notifications: "Always")
      event = make_event(number_of_tickets: 1, organizer_id: organizer.id)
      user = make_user(email: "applicant@test.de")
      make_application(event, { applicant_id: user.id + 1 })

      sign_in_as(user)

      application = make_draft(event, { applicant_id: user.id })

      post :submit, params: {
        event_id: event.id,
        id: application.id,
        application: {
          email: user.email,
          email_confirmation: user.email,
          terms_and_conditions: '1'
        }
      }
      reminder_email = ActionMailer::Base.deliveries.last
      assert_equal(
        reminder_email.subject,
        "Your event received more applications than available tickets."
      )
    end

    it 'sends an email to the organizer if they have decided that want to get'\
      'informed when the event reached the maximum number of applications only once' do
      organizer = make_user(capacity_email_notifications: "once")
      event = make_event(number_of_tickets: 1, organizer_id: organizer.id)
      user = make_user(email: "applicant@test.de")
      make_application(event, { applicant_id: user.id + 1 })

      event.number_of_tickets = 2

      make_application(event, { applicant_id: user.id + 2 })

      sign_in_as(user)

      application = make_draft(event, { applicant_id: user.id })

      post :submit, params: {
        event_id: event.id,
        id: application.id,
        application: {
          email: user.email,
          email_confirmation: user.email,
          terms_and_conditions: '1'
        }
      }
      reminder_emails = []
      emails = ActionMailer::Base.deliveries
      emails.each do |email|
        if email.subject == "Your event received more applications than available tickets."
          reminder_emails << email
        end
      end

      assert_equal 1, reminder_emails.length
    end
  end

  describe '#destroy' do
    it 'users can delete their own applications' do
      user = make_user(admin: false)
      sign_in_as(user)

      event = make_event
      application = make_application(event)
      applications = event.applications

      assert_equal 1, applications.count

      delete :destroy, params: { event_id: event.id, id: application.id }

      assert_redirected_to user_applications_path(user.id)
      assert_equal 0, applications.count
    end

    it 'proper redirects visitors' do
      event = make_event
      application = make_application(event)
      applications = event.applications

      assert_equal 1, applications.count

      delete :destroy, params: { event_id: event.id, id: application.id }

      assert_redirected_to sign_in_path
      assert_equal 1, applications.count
    end
  end
end
