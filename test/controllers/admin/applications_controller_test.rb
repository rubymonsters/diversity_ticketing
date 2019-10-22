require 'test_helper'

module Admin
  class ApplicationsControllerTest < ActionController::TestCase
    describe '#show' do
      it 'redirects visitors' do
        event = make_event
        application = make_application(event)

        get :show, params: { event_id: event.id, id: application.id }

        assert_redirected_to sign_in_path
      end

      it 'redirects non-admin users' do
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

        assert_redirected_to admin_event_path(event)
        assert_equal(
          "You cannot view a draft.",
          flash[:notice]
        )
      end

      it 'redirects admin to applications overview if the event has been deleted' do
        user = make_user
        event = make_event(deleted: true)
        application = make_application(event, applicant_id: user.id)

        admin = make_admin
        sign_in_as(admin)

        get :show, params: { event_id: event.id, id: application.id }

        assert_redirected_to admin_path
        assert_equal(
          "You cannot view your application as the event you applied for has been removed from "\
          "Diversity Tickets",
          flash[:notice]
        )
      end
    end

    describe '#destroy' do
      it 'properly redirects after successful deletion' do
        user = make_user(admin: true)
        sign_in_as(user)

        event = make_event
        application = make_application(event)
        applications = event.applications

        assert_equal 1, applications.count

        delete :destroy, params: { event_id: event.id, id: application.id }

        assert_redirected_to admin_event_path(event)
        assert_equal 0, applications.count
      end
    end
  end
end
