require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  test "index action shows only approved events" do 
  	approved_event = make_event(true)
  	unapproved_event = make_event(false, 'Other')

  	get :index

  	assert_select "h3", {count: 1, text: approved_event.name}
 
  	assert(css_select("h3").none? { |element| element.text == unapproved_event.name })
  end
end
