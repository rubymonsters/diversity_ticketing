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

      post :approve, params: { id: event.id }

      event.reload

      assert_equal(true, event.approved?)
    end

    it 'correctly redirects non-admin users' do
      event = make_event
      user = make_user(admin: false)
      sign_in_as(user)

      post :approve, params: { id: event.id }

      assert_redirected_to root_path

      event.reload

      assert_equal(false, event.approved?)
    end

    it 'correctly redirects visitors' do
      event = make_event

      post :approve, params: { id: event.id }

      assert_redirected_to sign_in_path

      event.reload

      assert_equal(false, event.approved?)
    end
  end

  describe '#show' do
    it 'shows the event details page to admin' do
      admin = make_user(admin: true)
      event = make_event

      sign_in_as(admin)

      get :show, params: { id: event.id }

      assert_response :success
      assert_template :show
    end

    it 'correctly redirects non-admin users' do
      user = make_user(admin: false)
      event = make_event

      sign_in_as(user)

      get :show, params: { id: event.id }

      assert_redirected_to root_path
    end

    it 'correctly redirects visitors' do
      get :show, params: { id: make_event.id }

      assert_redirected_to sign_in_path
    end

    it 'shows the event details page in csv format to admin' do
      admin = make_user(admin: true)
      event = make_event

      sign_in_as(admin)

      get :show, params: { id: event.id }, format: :csv

      assert_equal request.format, :csv
    end
  end

  describe '#destroy' do
    it 'destroys event on delete and redirects to admin page if user is admin' do
      admin = make_user(admin: true)
      event = make_event
      events = Event.all

      sign_in_as(admin)

      assert_equal 1, events.count

      get :destroy, params: { id: event.id }

      assert_equal 0, events.count
      assert_redirected_to admin_url
    end
  end
end
