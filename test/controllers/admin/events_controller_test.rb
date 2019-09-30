require 'test_helper'

module Admin
  class EventsControllerTest < ActionController::TestCase
    before do
      make_application_process_options_handler
    end

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

    describe 'annual' do
      it 'allows admins to download a csv file with an annual report' do
        user = make_user(admin: true)
        sign_in_as(user)

        get :annual, format: :csv

        assert_equal response.header['Content-Type'], 'text/csv'
        assert_response :success
      end

      it 'does not allow not admins to download a csv file with an annual report' do
        user = make_user(admin: false)
        sign_in_as(user)

        get :annual

        assert_redirected_to root_path
      end
    end

    describe '#approve' do
      it 'correctly approves event' do
        event = make_event
        user = make_user(admin: true)
        sign_in_as(user)

        post :approve, params: { id: event.id , approve: { tweet: "1" } }

        event.reload

        assert_equal(true, event.approved?)
      end

      it 'correctly informs potential users that may be interested in the event' do
        interested_user_1 = make_user(email: "country_user@test.de", country_email_notifications: true, country: "Germany")
        interested_user_2 = make_user(email: "tag_user@test.de", tag_email_notifications: true)
        category = Category.create!(name: "Interesting category")
        tag = Tag.create!(name: "Interesting tag", category_id: category.id)
        tagging = Tagging.create!(tag_id: tag.id , user_id: interested_user_2.id)

        event = make_event
        tagging_2 = Tagging.create!(tag_id: tag.id , event_id: event.id)
        user = make_user(admin: true)
        sign_in_as(user)

        post :approve, params: { id: event.id , approve: { tweet: "1" } }

        event.reload

        emails = ActionMailer::Base.deliveries
        emails.each { |email| @notification_country = email if email.subject ==  "A new event in your country!"
                              @notification_tag = email if email.subject == "A new event of your interest!" }
        assert_equal @notification_country.to, [interested_user_1.email]
        assert_equal @notification_tag.to, [interested_user_2.email]
      end

      it 'correctly redirects non-admin users' do
        event = make_event
        user = make_user(admin: false)
        sign_in_as(user)

        post :approve, params: { id: event.id , approve: { tweet: "1" } }

        assert_redirected_to root_path

        event.reload

        assert_equal(false, event.approved?)
      end

      it 'correctly redirects visitors' do
        event = make_event

        post :approve, params: { id: event.id , approve: { tweet: "1" } }

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

    describe '#edit' do
      it 'loads correctly for admin users' do
        user = make_user(admin: true)
        event = make_event
        sign_in_as(user)

        get :edit, params: { id: event.id }

        assert_response :success
      end

      it 'redirects if user is not an admin' do
        user = make_user(admin: false)
        event_owner = make_user(email: 'different_address@example.org')
        event = make_event(
          name: 'BoringConf',
          organizer_id: event_owner.id,
          approved: false,
          deadline: 5.days.from_now
        )
        sign_in_as(user)

        get :edit, params: { id: event.id }

        assert_redirected_to root_path
      end
    end

    describe '#update' do
      it 'loads correctly for admin users' do
        user = make_user(admin: true)
        event = make_event(name: 'BoringConf')
        sign_in_as(user)

        put :update, params: { id: event.id, event: {name: 'MonstersConf'} }

        event.reload

        assert_equal 'MonstersConf', event.name
        assert_redirected_to admin_event_path(event)
      end

      it 'changes approval status when admin is updating' do
        admin = make_user(admin: true)
        event_owner = make_user(
          admin: false,
          email: 'different_address@example.org'
        )
        event = make_event(
          approved: false,
          organizer_id: event_owner.id,
          deadline: 5.days.from_now
        )
        sign_in_as(admin)

        put :update, params: { id: event.id, event: { approved: true } }

        event.reload

        assert_redirected_to admin_event_path(event)
        assert_equal true, event.approved?
      end

      it 'rerenders edit when event update was not successful' do
        admin = make_user(admin: true)
        event_owner = make_user(
          admin: false,
          email: 'different_address@example.org'
        )
        event = make_event(
          approved: false,
          organizer_id: event_owner.id,
          deadline: 5.days.from_now
        )
        sign_in_as(admin)

        put :update, params: { id: event.id, event: { name: '' } }

        assert_template :edit
      end

      it 'renders a forbidden 403 status code when unauthorized user tries to update event info' do
        user = make_user
        organizer = make_user( email: 'other@example.org' )
        event = make_event( organizer_id: organizer.id )
        sign_in_as(user)

        put :update, params: { id: event.id, event: { name: 'Fakename' } }

        assert_redirected_to root_path
        assert_equal event.name, 'Event'
      end
    end
  end
end
