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
end
