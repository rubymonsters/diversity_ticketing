require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  test "successfully creates event and sends email" do 
    #create admin
    make_admin

    post :create, event: {
          name: 'Event',
          start_date: 1.week.from_now,
          end_date: 2.weeks.from_now,
          description: 'Sed ut perspiciatis unde omnis.',
          organizer_name: 'Klaus Mustermann',
          organizer_email: 'klaus@example.com',
          organizer_email_confirmation: 'klaus@example.com',
          website: 'http://google.com',
          code_of_conduct: 'http://coc.website',
          city: 'Berlin',
          country: 'Germany',
          deadline: 5.days.from_now,
          number_of_tickets: 10,
          approved: false
        }

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

    assert_select "a", {count: 1, text: "Show past events"}, "This page must contain anchor that says 'Show past events'"
  end

  test "index action does not show link to past events if there are no past events" do
    get :index

    assert_select "a", {count: 0, text: "Show past events"}, "This page must contain no anchors that say 'Show past events'"
  end
end
