require 'test_helper'

class ApplicationsControllerTest < ActionController::TestCase
  describe '#show' do
    it 'does not show application to visitors' do
      event = make_event
      application = make_application(event)

      get :show, event_id: event.id, id: application.id

      assert_redirected_to sign_in_path
    end

    it 'does not show application to non-admin users' do
      user = make_user(admin: false)
      sign_in_as(user)

      event = make_event
      application = make_application(event)

      get :show, event_id: event.id, id: application.id

      assert_redirected_to root_path
    end

    it 'shows application to admin users' do
      user = make_user(admin: true)
      sign_in_as(user)

      event = make_event
      application = make_application(event)

      get :show, event_id: event.id, id: application.id

      assert_response :success
    end

    it 'raise exception if application does not exist' do
      user = make_user(admin: true)
      sign_in_as(user)

      event = make_event

      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, event_id: event.id, id: 1
      end
    end
  end

  describe '#new' do
    it 'redirects to the event if the application process is run by the organizer' do
      event = make_event(application_process: 'application_by_organizer',
                         application_link: 'http://www.something.org')

      post :new,
        event_id: event.id

      assert_redirected_to event
    end

    it 'adds a new application if the selection process is not run by organizer' do
      event = make_event

      post :new,
        event_id: event.id

      assert_response :success
    end

  end

  describe '#create' do
    it 'proper redirects after successful application' do
      event = make_event

      post :create,
        event_id: event.id,
        application: {
          attendee_info_1: 'some text',
          attendee_info_2: 'some text',
          name: 'Joe',
          email: 'joe@test.com',
          email_confirmation: 'joe@test.com',
          terms_and_conditions: '1',
          event: event
        }

      assert_redirected_to event
    end

    it 'redirects to the event if the application process is run by the organizer' do
      event = make_event(application_process: 'application_by_organizer',
                         application_link: 'http://www.something.org')

      post :create,
        event_id: event.id

      assert_redirected_to event
    end

    it 'does not redirect after failed validations' do
      event = make_event

      post :create,
        event_id: event.id,
        application: {
          name: 'Joe'
        }

      assert_response :success
    end

    it 'does not redirect when terms and conditions are not accepted' do
      event = make_event

      post :create,
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

      assert_response :success
    end
  end

  describe '#destroy' do
    it 'proper redirects after successful deletion' do
      user = make_user(admin: true)
      sign_in_as(user)


      event = make_event
      application = make_application(event)

      delete :destroy, event_id: event.id, id: application.id

      assert_redirected_to event_admin_path(event)
    end

    it 'proper redirects non-admin users' do
      user = make_user(admin: false)
      sign_in_as(user)

      event = make_event
      application = make_application(event)

      delete :destroy, event_id: event.id, id: application.id

      assert_redirected_to root_path
    end

    it 'proper redirects visitors' do
      event = make_event
      application = make_application(event)

      delete :destroy, event_id: event.id, id: application.id

      assert_redirected_to sign_in_path
    end
  end
end
