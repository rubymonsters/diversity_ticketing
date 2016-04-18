require 'test_helper'

class ApplicationsControllerTest < ActionController::TestCase

  # GET show
  test 'shows application to admin users' do
    user = make_user(admin: true)
    sign_in_as(user)

    event = make_event
    application = make_application(event)

    get :show, event_id: event.id, id: application.id

    assert_response :success
  end

  test 'does not show application to non-logged-in users' do
    event = make_event
    application = make_application(event)

    get :show, event_id: event.id, id: application.id

    assert_redirected_to sign_in_path
  end

  test 'raise exception if application does not exist' do
    user = make_user(admin: true)
    sign_in_as(user)

    event = make_event

    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, event_id: event.id, id: 1
    end
  end

  # POST create
  test 'proper redirection after successful application' do
      event = make_event

      post :create, event_id: event.id,
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

  test 'no redirection after failed validations' do
    event = make_event

    post :create, event_id: event.id,
                  application: {
                    name: 'Joe'
                  }

    assert_response :success
  end

  test 'no redirection when terms and conditions are not accepted' do
    event = make_event

    post :create, event_id: event.id,
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

  # DELETE destroy
  test 'proper redirection after successful deletion' do
    user = make_user(admin: true)
    sign_in_as(user)


    event = make_event
    application = make_application(event)

    delete :destroy, event_id: event.id, id: application.id

    assert_redirected_to event_admin_path(event)
  end
end
