require 'test_helper'

feature 'Event' do
  def setup
    @user = make_user
    @admin = make_admin
  end

  test 'shows a logo image if the event has a logo' do
    sign_in_as_user
    make_event(name: 'The Event', approved: true, logo: 'logo-image')

    visit events_path

    assert page.text.include?('The Event')
    assert_match /logo-image/, page.body
    assert_no_match /event-default-.*\.png/, page.body
  end

  test 'shows a default image if the event does not have a logo' do
    sign_in_as_user
    make_event(name: 'The Event', approved: true)

    visit events_path

    assert page.text.include?('The Event')
    assert_match /event-default-.*\.png/, page.body
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
