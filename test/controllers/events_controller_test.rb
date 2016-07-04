require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  test "successfully creates event and sends email" do
    #create admin
    make_admin

    post :create, event: make_event_form_params

    assert_equal 'You have successfully created Event.', flash[:notice]
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
    params = make_event_form_params(application_process: 'selection_by_organizer',
                                    data_protection_confirmation: '1')

    post :create, event: params

    assert_response :redirect
    assert Event.first.application_process == 'selection_by_organizer'
  end

  test "choosing selection by organizer and not agreeing to protect data fails" do
    params = make_event_form_params(application_process: 'selection_by_organizer',
                                    data_protection_confirmation: nil)

    post :create, event: params

    assert Event.all.empty?
  end

  test "choosing selection not by organizer (instead e.g. Travis Foundation) and not agreeing to protect data still creates event correctly" do
    params = make_event_form_params(application_process: 'selection_by_travis')

    post :create, event: params

    assert_equal false, Event.last.application_process == 'selection_by_organizer'
  end

  test "index action has apply link for event with deadline in the future" do
    @event = make_event(approved: true)

    get :index

    assert_select "a", {count: 1, text: "Apply"}, "This page must contain 'Apply' link"
  end

  test "index action has apply link for event where deadline is today" do
    @event = make_event(approved: true, deadline: Date.today)

    get :index

    assert_select "a", {count: 1, text: "Apply"}, "This page must contain 'Apply' link"
  end

  test "index action has no apply link for event with deadline in the past" do
    @past_event = make_event(start_date: 1.week.ago, end_date: 1.week.ago, deadline: 2.weeks.ago, approved: true, name: 'Other')

    get :index

    assert_select "a", {count: 0, text: "Apply"}, "This page should not contain 'Apply' link"
  end

  test "show action has apply link for event with deadline in the future" do
    @event = make_event(approved: true)

    get :show, :id => @event.id

    assert_select "a", {count: 1, text: "Apply"}, "This page must contain 'Apply' link"
  end

  test "show action has apply link for event where deadline is today" do
    @event = make_event(approved: true, deadline: Date.today)

    get :show, :id => @event.id

    assert_select "a", {count: 1, text: "Apply"}, "This page must contain 'Apply' link"
  end

  test "show action has no apply link for event with deadline in the past" do
    @past_event = make_event(start_date: 1.week.ago, end_date: 1.week.ago, deadline: 2.weeks.ago, approved: true, name: 'Other')

    get :show, :id => @past_event.id

    assert_select "a", {count: 0, text: "Apply"}, "This page should not contain 'Apply' link"
  end
end
