require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  test "successfully creates event and sends email" do
    admin_user = make_admin
    sign_in_as(admin_user)

    post :create, event: make_event_form_params

    assert_equal "Thank you for submitting Event. We will review it shortly.", flash[:notice]
    assert_redirected_to events_path
    admin_email = ActionMailer::Base.deliveries.find {|d| d.to == ["admin@woo.hoo"]}
    assert_equal admin_email.subject, "A new event has been submitted."
    organizer_email = ActionMailer::Base.deliveries.find {|d| d.to == ["klaus@example.com"]}
    assert_equal organizer_email.subject, "You submitted a new event."
    assert_equal Event.last.name, 'Event'
    assert_equal Event.last.approved, false
  end

  test "index action shows only approved events" do
    approved_event = make_event(approved: true)
    unapproved_event = make_event(name: 'Other')

    get :index

    assert_select "h3", {count: 1, text: approved_event.name}

    assert(css_select("h3").none? { |element| element.text == unapproved_event.name })
  end

  test "index action shows only future events" do
    future_event = make_event(approved: true)
    past_event = make_event(start_date: 1.week.ago, end_date: 1.week.ago, deadline: 2.weeks.ago, approved: true, name: 'Other')

    get :index

    assert_select "h3", {count: 1, text: future_event.name}

    assert(css_select("h3").none? { |element| element.text == past_event.name })
  end

  test "index action shows link to past events if there are past events" do
    make_event(start_date: 1.week.ago, end_date: 1.week.ago, deadline: 2.weeks.ago, approved: true, name: 'Other')

    get :index

    assert_select "a", {count: 1, text: "past events"}, "This page must contain anchor that says 'Show past events'"
  end

  test "index action does not show link to past events if there are no past events" do
    get :index

    assert_select "a", {count: 0, text: "Show past events"}, "This page must contain no anchors that say 'Show past events'"
  end

  test "choosing selection by organizer and agreeing to protect data creates event correctly" do
<<<<<<< HEAD
    params = make_event_form_params(application_process: 'selection_by_organizer',
                                    data_protection_confirmation: '1')
=======
    user = make_user
    sign_in_as(user)

    params = make_event_form_params(  selection_by_organizer: true,
                                      data_protection_confirmation: '1')
>>>>>>> fix tests that were broken by rebase

    post :create, event: params

    assert_response :redirect
    assert Event.first.application_process == 'selection_by_organizer'
  end

  test "choosing selection by organizer and not agreeing to protect data fails" do
    params = make_event_form_params(application_process: 'selection_by_organizer',
                                    data_protection_confirmation: '0')

    post :create, event: params

    assert Event.all.empty?
  end

  test "choosing selection not by organizer (instead e.g. Travis Foundation) and not agreeing to protect data still creates event correctly" do
<<<<<<< HEAD
    params = make_event_form_params(application_process: 'selection_by_travis')

    post :create, event: params

    assert_equal false, Event.last.application_process == 'selection_by_organizer'
  end

  test "irrelevant selection & application process data is thrown away" do
    params = make_event_form_params(
      application_process: 'selection_by_travis',
      data_protection_confirmation: '1',
      application_link: 'somelink.tada'
    )
=======
    user = make_user
    sign_in_as(user)

    params = make_event_form_params
>>>>>>> fix tests that were broken by rebase

    post :create, event: params

    assert_equal false, Event.last.application_process == 'selection_by_organizer'
  end

  test "index action has apply link for event with deadline in the future" do
    @event = make_event(approved: true)

    get :index

    assert_select ".button_to", {count: 1, value: "Apply", disabled: false}, "This page must contain 'Apply' link"
  end

  test "index action has apply link for event where deadline is today" do
    @event = make_event(approved: true, deadline: Date.today)

    get :index

    assert_select ".button_to", {count: 1, value: "Apply", disabled: false}, "This page must contain 'Apply' link"
  end

  test "index action has no apply link for event with deadline in the past" do
    @past_event = make_event(start_date: 1.week.ago, end_date: 1.week.ago, deadline: 2.weeks.ago, approved: true, name: 'Other')

    get :index

    assert_select ".button_to", {count: 0, value: "Apply"}, "This page should not contain 'Apply' button"
  end

  test "show action has apply link for event with deadline in the future" do
    @event = make_event(approved: true)

    get :show, :id => @event.id

    assert_select ".button_to", {count: 1, value: "Apply", disabled: false}, "This page must contain 'Apply' button"
  end

  test "show action has apply link for event where deadline is today" do
    @event = make_event(approved: true, deadline: Date.today)

    get :show, :id => @event.id

    assert_select ".button_to", {count: 1, value: "Apply", disabled: false}, "This page must contain 'Apply' button"
  end

  test "show action has no apply link for event with deadline in the past" do
    @past_event = make_event(start_date: 1.week.ago, end_date: 1.week.ago, deadline: 2.weeks.ago, approved: true, name: 'Other')

    get :show, :id => @past_event.id

    assert_select ".button_to", {count: 1, value: "Apply", disabled: true}, "This page should contain disabled 'Apply' button"
  end

  test "index action shows event with end_date in the future" do
    @event = make_event(approved: true, start_date: 1.weeks.from_now, end_date: 2.weeks.from_now)

    get :index

    assert_select ".event", {count: 1}, "This page must contain an event."
  end

  test "new action requires logged-in user" do
    get :new

    assert_redirected_to sign_in_path
  end

  test "create action requires logged-in user" do
    post :create, event: make_event_params

    assert_redirected_to sign_in_path
  end

  test "preview action requires logged-in user" do
    post :preview, event: make_event_params

    assert_redirected_to sign_in_path
  end

  test "preview loads correctly with logged-in user" do
    user = make_user
    sign_in_as(user)
    event_params = make_event_params

    post :preview, event: event_params

    assert_response :success
  end

  test "create actions assigns event to correct organizer" do
    user = make_user
    sign_in_as(user)
    event_params = make_event_params(name: "MonsterConf")

    post :create, event: event_params

    event = Event.find_by(name: "MonsterConf")
    
    assert_equal user.id, event.organizer_id
  end
end
