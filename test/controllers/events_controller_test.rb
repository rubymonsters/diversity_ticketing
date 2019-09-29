require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  before do
    make_application_process_options_handler
  end
  
  describe '#create' do
    it 'successfully creates event and sends etest' do
      admin_user = make_admin
      sign_in_as(admin_user)

      ActionMailer::Base.deliveries.clear

      post :create, params: {
        event: make_event_form_params({
          name: 'Ruby Conf',
          organizer_name: 'Ruby Fakename',
          organizer_email: 'ruby@example.com',
          organizer_email_confirmation: 'ruby@example.com',
          application_process: 'selection_by_travis'
        })
    }

      assert_equal 'Thank you for submitting Ruby Conf. We will review it shortly.', flash[:notice]
      assert_redirected_to events_path

      admin_email = ActionMailer::Base.deliveries.find {|d| d.to == ['admin@woo.hoo']}
      assert_equal admin_email.subject, 'A new event has been submitted.'
      assert_match admin_email.body, /Ruby Conf/
      assert_match admin_email.body, /Organizer Name: Ruby Fakename/
      assert_match admin_email.body, /Organizer Email: ruby@example.com/
      assert_match admin_email.body, /Application Process: Selection by travis/

      organizer_email = ActionMailer::Base.deliveries.find {|d| d.to == ['ruby@example.com']}
      assert_equal organizer_email.subject, 'You submitted a new event.'

      assert_equal Event.last.name, 'Ruby Conf'
      assert_equal Event.last.approved, false
    end

    describe 'user chooses selection by organizer and agrees to protect data' do
      it 'creates event correctly' do
        params = make_event_form_params(
          application_process: 'selection_by_organizer',
          data_protection_confirmation: '1'
        )
        user = make_user
        sign_in_as(user)

        post :create, params: { event: params }

        assert_response :redirect
        assert Event.first.application_process == 'selection_by_organizer'
      end
    end

    describe 'user chooses selection by organizer and  does not agree to protect data' do
      it 'does not create event' do
        params = make_event_form_params(
          application_process: 'selection_by_organizer',
          data_protection_confirmation: '0'
        )
        user = make_user
        sign_in_as(user)

        post :create, params: { event: params }

        assert Event.all.empty?
      end
    end

    describe 'user does not choose selection by organizer and does not agree to protect data' do
      it 'creates event correctly' do
        params = make_event_form_params(application_process: 'selection_by_travis')
        user = make_user
        sign_in_as(user)

        post :create, params: { event: params }

        assert_equal false, Event.last.application_process == 'selection_by_organizer'
      end
    end

    it 'it throws away irrelevant selection & application process data' do
      params = make_event_form_params(
        application_process: 'selection_by_travis',
        data_protection_confirmation: '1',
        application_link: 'somelink.tada'
      )
      user = make_user
      sign_in_as(user)

      post :create, params: { event: params }

      assert_equal false, Event.last.application_process == 'selection_by_organizer'
    end

    it 'requires logged-in user' do
      post :create, params: { event: make_event_params }

      assert_redirected_to sign_in_path
    end

    it 'assigns event to correct organizer' do
      user = make_user
      event_params = make_event_params(name: 'MonsterConf')
      sign_in_as(user)

      post :create, params: { event: event_params }

      event = Event.find_by(name: 'MonsterConf')

      assert_equal user.id, event.organizer_id
    end
  end

  describe '#index' do
    it 'shows approved events with end date in the future' do
      make_event(
        approved: true,
        start_date: 1.weeks.from_now,
        end_date: 2.weeks.from_now
      )

      get :index

      assert_select '.event',
        {count: 1},
        'This page must contain an event.'
    end

    it 'does not show unapproved events' do
      approved_event = make_event(approved: true)
      unapproved_event = make_event(name: 'Other')

      get :index

      assert_select 'h3', {count: 1, text: approved_event.name}

      assert(css_select('h3').none? { |element| element.text == unapproved_event.name })
    end

    it 'does not show past events' do
      future_event = make_event(approved: true)
      past_event = make_event(
        start_date: 1.week.ago,
        end_date: 1.week.ago,
        deadline: 2.weeks.ago,
        approved: true,
        name: 'Other'
      )

      get :index

      assert_select 'h3', {count: 1, text: future_event.name}

      assert(css_select('h3').none? { |element| element.text == past_event.name })
    end

    it 'shows link to past events if there are past events' do
      make_event(
        start_date: 1.week.ago,
        end_date: 1.week.ago,
        deadline: 2.weeks.ago,
        approved: true,
        name: 'Other'
      )

      get :index

      assert_select 'a',
        {count: 1, text: 'Show past events'},
        "This page must contain anchor that says 'Show past events'"
    end

    it 'does not show link to past events if there are no past events' do
      get :index

      assert_select 'a',
        {count: 0, text: 'Show past events'},
        "This page must contain no anchors that say 'Show past events'"
    end

    it 'has apply link for event with deadline in the future' do
      make_event(approved: true)

      get :index

      assert_select '.button_to',
        {count: 1, value: 'Apply', disabled: false},
        "This page must contain 'Apply' link"
    end

    it 'has apply link for event where deadline is today' do
      make_event(approved: true, deadline: Date.today)

      get :index

      assert_select '.button_to',
        {count: 1, value: 'Apply', disabled: false},
        "This page must contain 'Apply' link"
    end

    it 'has no apply link for event with deadline in the past' do
      make_event(
        start_date: 1.week.ago,
        end_date: 1.week.ago,
        deadline: 2.weeks.ago,
        approved: true,
        name: 'Other'
      )

      get :index

      assert_select '.button_to',
        {count: 0, value: 'Apply'},
        "This page should not contain 'Apply' button"
    end
  end

  describe '#index_past' do
    it 'shows only and all past and approved events' do
      past_event1 = make_event(
        start_date: 1.week.ago,
        end_date: 1.week.ago,
        deadline: 2.weeks.ago,
        approved: true,
        name: 'Past1'
      )
      past_event2 = make_event(
        start_date: 2.weeks.ago,
        end_date: 2.weeks.ago,
        deadline: 3.weeks.ago,
        approved: true,
        name: 'Past2'
      )
      past_unapproved_event = make_event(
        start_date: 2.weeks.ago,
        end_date: 2.weeks.ago,
        deadline: 3.weeks.ago,
        approved: false,
        name: 'Past3'
      )
      future_approved_event = make_event(
        start_date: 1.week.ago,
        end_date: 10.days.from_now,
        deadline: 9.days.from_now,
        approved: true,
        name: 'Approved'
      )
      future_unapproved_event = make_event(
        start_date: 1.week.ago,
        end_date: 10.days.from_now,
        deadline: 9.days.from_now,
        approved: false,
        name: 'Unapproved'
      )

      events = Event.approved.past

      get :index_past

      assert_equal events.length, 2
      assert_equal events.sort, [past_event1, past_event2].sort
    end
  end

  describe '#new' do
    it 'redirects not logged-in user' do
      get :new

      assert_equal "Please sign in to continue.", flash[:notice]
      assert_redirected_to sign_in_path
    end

    it 'loads correctly with logged-in user' do
      user = make_user
      sign_in_as(user)

      get :new

      assert_response :success
    end
  end

  describe '#show' do
    it 'has apply link for event with deadline in the future' do
      event = make_event(approved: true)

      get :show, params: { id: event.id }

      assert_select '.button_to',
        {count: 1, value: 'Apply', disabled: false},
        "This page must contain 'Apply' button"
    end

    it 'has apply link for event where deadline is today' do
      event = make_event(approved: true, deadline: Date.today)

      get :show, params: { id: event.id }

      assert_select '.button_to',
        {count: 1, value: 'Apply', disabled: false},
        "This page must contain 'Apply' button"
    end

    it 'has no apply link for event with deadline in the past' do
      past_event = make_event(
        start_date: 1.week.ago,
        end_date: 1.week.ago,
        deadline: 2.weeks.ago,
        approved: true,
        name: 'Other'
      )

      get :show, params: { id: past_event.id }

      assert_select '.button_to',
        {count: 1, value: 'Apply', disabled: true},
        "This page should contain disabled 'Apply' button"
    end

    it 'redirects back and sends alert if event is not approved and current_user is not organizer' do
      user = make_user
      event = make_event(approved: false)
      request.env["HTTP_REFERER"] = 'http://www.somewhere.net'
      sign_in_as(user)

      get :show, params: { id: event.id }

      assert_equal 'You are not allowed to access this event.', flash[:alert]
      assert_redirected_to request.env["HTTP_REFERER"]
    end
  end

  describe '#preview' do
    it 'redirects not logged-in user' do
      post :preview, params: { event: make_event_params }

      assert_redirected_to sign_in_path
    end

    it 'loads preview view correctly with logged-in user' do
      user = make_user
      event_params = make_event_params
      sign_in_as(user)

      post :preview, params: { event: event_params }

      assert_template :preview
    end

    it 'loads new view with logged-in user and invalid event params' do
      user = make_user
      event_params = { organizer_email: 'email.de' }
      sign_in_as(user)

      post :preview, params: { event: event_params }

      assert_template :new
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

    it 'loads correctly for event owner' do
      user = make_user(admin: false)
      event = make_event(
        organizer_id: user.id,
        approved: false,
        deadline: 5.days.from_now
      )
      sign_in_as(user)

      get :edit, params: { id: event.id }

      assert_response :success
    end

    it 'redirects event owner if event is closed' do
      user = make_user(admin: false)
      event = make_event(
        organizer_id: user.id,
        approved: false,
        deadline: 5.days.ago
      )
      sign_in_as(user)

      get :edit, params: { id: event.id }

      assert_redirected_to event_url(event)
    end

    it 'redirects if user is not owner of event' do
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

      assert_redirected_to event_url(event)
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
      assert_redirected_to "http://test.host/"
    end

    it 'loads correctly for event owner' do
      user = make_user(admin: false)
      event = make_event(
        name: 'BoringConf',
        organizer_id: user.id,
        approved: false,
        deadline: 5.days.from_now
        )
      sign_in_as(user)

      put :update, params: { id: event.id, event: {name: 'MonstersConf'} }

      event.reload

      assert_equal 'MonstersConf', event.name
      assert_redirected_to "http://test.host/"
    end

    it 'does not change approval status when event owner is updating' do
      user = make_user(admin: false)
      event = make_event(
        approved: false,
        organizer_id: user.id,
        deadline: 5.days.from_now
        )
      sign_in_as(user)

      put :update, params: { id: event.id, event: {approved: true} }

      event.reload

      assert_redirected_to "http://test.host/"
      assert_equal false, event.approved?
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

      assert_redirected_to "http://test.host/"
      assert_equal true, event.approved?
    end

    it 'rerenders edit when event update was not successful' do
      organizer = make_user
      event = make_event(organizer_id: organizer.id)
      sign_in_as(organizer)

      put :update, params: { id: event.id, event: { name: '' } }

      assert_template :edit
    end

    it 'renders a forbidden 403 status code when unauthorized user tries to update event info' do
      user = make_user
      organizer = make_user( email: 'other@example.org' )
      event = make_event( organizer_id: organizer.id )
      sign_in_as(user)

      put :update, params: { id: event.id, event: { name: 'Fakename' } }

      assert_response :forbidden
      assert_equal event.name, 'Event'
    end
  end

  describe '#destroy' do
    it 'deletes all the attributes of the event except the id and the country' do
      organizer = make_user
      event = make_event(name: "HOLA", organizer_id: organizer.id)
      event.update_attributes(start_date: 2.weeks.ago, end_date: 1.week.ago, deadline: 9.days.ago)
      event_id = event.id
      sign_in_as(organizer)

      delete :destroy, params: { id: event.id }

      assert_response :redirect
      event.reload
      assert_nil event.name
      assert_equal event_id, event.id
    end

    it 'deletes all the attributes of the applications from the event except the id and applicant_id' do
      organizer = make_user
      event = make_event(organizer_id: organizer.id)
      applicant = make_user(email: "other@example.com")
      application = make_application(event, applicant_id: applicant.id )
      event.update_attributes(start_date: 2.weeks.ago, end_date: 1.week.ago, deadline: 9.days.ago)
      application_id = application.id

      sign_in_as(organizer)

      delete :destroy, params: { id: event.id }

      application.reload
      assert_nil application.name
      assert_equal application_id, application.id
      assert_equal applicant.id, application.applicant_id
    end

    it 'renders a head forbidden if the user is not allowed to delete the event' do
      organizer = make_user
      user = make_user(email: "other@example.com")
      event = make_event(organizer_id: organizer.id)
      event.update_attributes(end_date: 1.week.ago)

      sign_in_as(user)

      delete :destroy, params: { id: event.id }

      assert_response :forbidden
    end

    it 'does not allow to delete an event that is still open' do
      organizer = make_user
      event = make_event(organizer_id: organizer.id)

      sign_in_as(organizer)

      delete :destroy, params: { id: event.id }

      assert_response :forbidden
    end
  end
end
