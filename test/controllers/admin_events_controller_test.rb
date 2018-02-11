require 'test_helper'

class AdminEventsControllerTest < ActionController::TestCase
  describe '#index' do
    it 'protect admin index from anonymous visitors, redirects to sign in' do
      get :index

      assert_redirected_to sign_in_path
    end

    it 'protect admin index from logged-in non-admins, redirects to root' do
      user = make_user
      sign_in_as(user)

      get :index

      assert_redirected_to root_path
    end

    it 'shows admin index to logged-in admins' do
      user = make_user(admin: true)
      sign_in_as(user)

      get :index

      assert_response :success
    end
  end

  describe '#approve' do
    it 'correctly approves event' do
      event = make_event
      user = make_user(admin: true)
      sign_in_as(user)

      TwitterWorker.expects(:announce_event).with(event).once

      post :approve, id: event.id

      event.reload

      assert_equal(true, event.approved?)
    end

    it 'correctly redirects non-admin users' do
      event = make_event
      user = make_user(admin: false)
      sign_in_as(user)

      post :approve, id: event.id

      assert_redirected_to root_path

      event.reload

      assert_equal(false, event.approved?)
    end

    it 'correctly redirects visitors' do
      event = make_event

      post :approve, id: event.id

      assert_redirected_to sign_in_path

      event.reload

      assert_equal(false, event.approved?)
    end
  end
end
