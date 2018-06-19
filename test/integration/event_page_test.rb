require 'test_helper'

feature 'Event' do
  def setup
    @user = make_user
    @admin = make_admin
    @event = make_event(organizer_id: @user.id, approved: true)
  end

  test 'does not show a Delete button if the Event is still open' do
    sign_in_as_user
    visit event_path(@event.id)
    assert_not page.has_link?("Delete")
  end

  test 'shows a Delete button if the Event has passed and the user is the organizer' do
    sign_in_as_user
    @event.update_attributes(start_date: 1.week.ago, end_date: 1.day.ago, deadline: 1.week.ago)
    visit event_path(@event.id)
    assert page.has_link?("Delete")
  end

  test 'does not show a Delete button if the user is not organizer' do
    @event.update_attributes(start_date: 1.week.ago, end_date: 1.day.ago, deadline: 1.week.ago)
    visit event_path(@event.id)
    assert_not page.has_link?("Delete")
  end

  test 'redirects to root after trying to visit a delete event page' do
    sign_in_as_user
    application = make_application(@event)

    @event.update_attributes(start_date: 1.week.ago, end_date: 1.day.ago, deadline: 1.week.ago)

    visit event_path(@event.id)

    assert page.has_link?("Delete")
    click_link("Delete")

    visit event_path(@event.id)
    
    assert page.text.include?('You are not allowed to access this event')
    assert root_path, current_path
  end

  test 'shows Your events in the breadcrumb if the user is an organizer' do
    sign_in_as_user
    make_event(name: 'The Event', approved: true, organizer_id: @user.id)

    visit events_path

    click_link 'The Event'

    assert page.text.include?('Your Events')
  end

  test 'shows Events in the breadcrumb if the user is not an organizer' do
    sign_in_as_user
    make_event(name: 'The Event', approved: true)

    visit events_path

    click_link 'The Event'

    assert page.text.include?('Events')
  end

  test 'shows Admin in the breadcrumb if the user is an Admin' do
    sign_in_as_admin
    make_event(name: 'The Event', approved: true, organizer_id: @user.id)

    visit events_path

    click_link 'The Event'

    assert page.text.include?('Admin')
  end
end
