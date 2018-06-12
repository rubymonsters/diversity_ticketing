require 'test_helper'

class ApplicationsControllerTest < ActionController::TestCase
  describe '#show' do
    it 'does not show application to visitors' do
      event = make_event
      application = make_application(event)

      get :show, params: { event_id: event.id, id: application.id }

      assert_redirected_to sign_in_path
    end

    it 'does not show application of other users to non-admin users' do
      user = make_user
      other_user = make_user(email: 'other@email.com')
      sign_in_as(user)

      event = make_event
      application = make_application(event, applicant_id: other_user.id)

      get :show, params: { event_id: event.id, id: application.id }

      assert_redirected_to root_path
    end

    it 'shows submitted application to admin users' do
      admin = make_admin
      sign_in_as(admin)

      event = make_event
      application = make_application(event)

      get :show, params: { event_id: event.id, id: application.id }

      assert_response :success
    end

    it 'redirects admin users to root if they try to see drafted applications' do
      admin = make_admin
      sign_in_as(admin)

      event = make_event
      draft = make_draft(event)

      get :show, params: { event_id: event.id, id: draft.id }

      assert_redirected_to root_path
    end

    it 'raise exception if application does not exist' do
      admin = make_admin
      sign_in_as(admin)

      event = make_event

      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, params: { event_id: event.id, id: 1 }
      end
    end
  end

  describe '#new' do
    it 'redirects to the event if the application process is run by the organizer' do
      event = make_event(application_process: 'application_by_organizer',
                         application_link: 'http://www.something.org')

      get :new, params: { event_id: event.id }

      assert_redirected_to event
    end

    it 'adds a new application if the selection process is not run by organizer' do
      event = make_event
      user = make_user
      sign_in_as(user)

      get :new, params: { event_id: event.id }

      assert_response :success
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
        commit: 'Submit Application'
      }

      assert_redirected_to event_path(event.id)
    end

    it 'redirects to the event if the application process is run by the organizer' do
      event = make_event(application_process: 'application_by_organizer',
                         application_link: 'http://www.something.org')

      post :create, params: { event_id: event.id }

      assert_redirected_to event
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
  end

  describe '#admin_destroy' do
    it 'properly redirects after successful deletion' do
      user = make_user(admin: true)
      sign_in_as(user)

      event = make_event
      application = make_application(event)
      applications = event.applications

      assert_equal 1, applications.count

      delete :admin_destroy, params: { event_id: event.id, id: application.id }

      assert_redirected_to event_admin_path(event)
      assert_equal 0, applications.count
    end
  end

  describe '#destroy' do
    it 'non-admin users can delete their own applications' do
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
