require 'test_helper'

feature 'Event Overview' do
  def setup
    @user = make_user
    @admin = make_admin
  end

  test 'shows a link to Apply if the user did not apply or create a draft for the event' do
    @event = make_event(approved: true)

    sign_in_as_user

    visit events_path

    click_button("Apply")

    assert_equal current_path, new_event_application_path(@event.id)
  end

  test 'shows a link to Your Draft if the user already created a draft for the event' do
    @event = make_event(approved: true)
    application = make_draft(@event, applicant_id: @user.id)
    sign_in_as_user

    visit events_path

    assert_not page.has_content?("Apply")

    click_button("Your Draft")

    assert_equal event_application_path(@event.id, application.id), current_path
  end

  test 'shows a link to Your Application if the user already submitted an application for the event' do
    @event = make_event(approved: true)    
    application = make_application(@event, applicant_id: @user.id)
    sign_in_as_user

    visit events_path

    assert_not page.has_content?("Apply")

    page.all('a', text:"Your Application")
    click_button("Your Application")

    assert_equal event_application_path(@event.id, application.id), current_path
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
