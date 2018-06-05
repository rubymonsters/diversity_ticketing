require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  describe '#update' do
    it 'does not allow logged-in user to edit anyone else\'s data' do
      user1 = make_user(email: 'a@example.org')
      user2 = make_user(email: 'b@example.org')
      sign_in_as(user1)

      put :update, params: { id: user2.id, user: {email: 'c@example.org'} }

      user2.reload

      assert_equal 'b@example.org', user2.email
      assert_redirected_to root_path
      assert_equal "We're sorry. You don't have permission to access this page.", flash[:alert]
    end

    it 'does not anonymous user to edit anyone\'s data' do
      user = make_user(email: 'a@example.org')

      put :update, params: { id: user.id, user: {email: 'b@example.org'} }

      user.reload

      assert_equal 'a@example.org', user.email
      assert_redirected_to sign_in_url
    end

    it 'allows user to edit their data' do
      user = make_user(email: 'la@le.lu')
      sign_in_as(user)

      put :update, params: { id: user.id, user: { email: 'cool@email.add', password: '654321' } }
      user.reload

      assert_equal user.email, 'cool@email.add'
      assert_redirected_to edit_user_path(user)
    end

    it 're-renders edit form if user attributes are invalid' do
      user = make_user(email: 'ta@da.aa')
      sign_in_as(user)

      put :update, params: { id: user.id, user: { email: '' } }
      user.reload

      assert_equal user.email, 'ta@da.aa'
      assert_response :success
    end
  end

  describe '#edit' do
    it 'does not allow logged-in user to see anyone else\'s data' do
      user1 = make_user(email: 'a@example.org')
      user2 = make_user(email: 'b@example.org')
      sign_in_as(user1)

      get :edit, params: { id: user2.id }

      assert_redirected_to root_path
      assert_equal "We're sorry. You don't have permission to access this page.", flash[:alert]
    end

    it 'does not allow anonymous user to see anyone\'s data' do
      user = make_user(email: 'a@example.org')

      get :edit, params: { id: user.id }

      assert_redirected_to sign_in_url
    end
  end

  describe '#show' do
    it 'does not allow logged-in user to see anyone else\'s data' do
      user1 = make_user(email: 'a@example.org')
      user2 = make_user(email: 'b@example.org')
      sign_in_as(user1)

      get :show, params: { id: user2.id }

      assert_redirected_to root_path
      assert_equal "We're sorry. You don't have permission to access this page.", flash[:alert]
    end

    it 'does not allow anonymous user to see anyone\'s data' do
      user = make_user

      get :show, params: { id: user.id }

      assert_redirected_to sign_in_url
    end

    it 'shows categorized events for the user' do
      user = make_user
      approved_event = make_event(approved: true, organizer_id: user.id, end_date: 10.days.from_now)
      unapproved_event = make_event(organizer_id: user.id, end_date: 10.days.from_now)
      past_event = make_event(organizer_id: user.id, start_date: Time.now.yesterday, end_date: Time.now.yesterday)

      categorized_user_events = {
        approved: user.events.approved.upcoming,
        unapproved: user.events.unapproved.upcoming,
        past: user.events.past
      }

      sign_in_as(user)

      get :show, params: { id: user.id }

      assert_equal categorized_user_events.length, 3
      assert categorized_user_events[:approved].include?(approved_event)
      assert categorized_user_events[:unapproved].include?(unapproved_event)
      assert categorized_user_events[:past].include?(past_event)
    end
  end

  describe '#destroy' do
    it 'deletes user from database' do
      user1 = make_user(email: 'a@example.org')
      user2 = make_user(email: 'b@example.org')

      sign_in_as(user2)

      assert_equal 'b@example.org', User.last.email

      delete :destroy, params: { id: user2.id }

      assert_redirected_to root_path
      assert_equal "Your Account has been deleted successfully.", flash[:alert]
      assert_equal 'a@example.org', User.last.email
    end
  end
end
