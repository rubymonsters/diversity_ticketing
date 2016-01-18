require 'test_helper'

class EventsControllerTest < ActionController::TestCase
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

    assert_select "a", {count: 1, text: "Show past events"}, "This page must contain anchor that says 'Show past events'"
  end

  test "index action does not show link to past events if there are no past events" do
    get :index

    assert_select "a", {count: 0, text: "Show past events"}, "This page must contain no anchors that say 'Show past events'"
  end
end
