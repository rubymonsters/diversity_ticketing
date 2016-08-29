require 'test_helper'

class AdminEventsControllerTest < ActionController::TestCase
  test 'protect admin index from anonymous visitors, redirects to sign in' do
    get :index

    assert_redirected_to sign_in_path
  end

  test 'protect admin index from logged-in non-admins, redirects to root' do
    user = make_user
    sign_in_as(user)

    get :index

    assert_redirected_to root_path
  end

  test 'shows admin index to logged-in admins' do
    user = make_user(admin: true)
    sign_in_as(user)

    get :index

    assert_response :success
  end

  # The following test should
  # - make an event
  # - make an admin user
  # - sign in as that user
  # - approve the event
  # - show the correct results: event is approved (default: unapproved)
  # - check if a tweet was made
  test 'approve action correctly approves event' do
    event = make_event
    user = make_user(admin: true)
    sign_in_as(user)

    TwitterWorker.expects(:announce_event).with(event).once

    post :approve, id: event.id

    event.reload

    assert_equal(true, event.approved?)
  end
end
