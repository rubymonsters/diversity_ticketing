require 'test_helper'

feature 'Event' do
  test 'Events are displayed in the events page' do
    make_user
    sign_in_as_user
    make_event(name: 'The Event', approved: true, logo: 'logo-image')

    visit root_path

    click_link 'Events'

    assert page.text.include?('The Event')
    assert page.body.include?('logo-image')
    assert_not page.body.include?('event-default')

    make_event(name: 'The Event 2', approved: true)

    refresh

    assert page.text.include?('The Event 2')
    assert page.body.include?('event-default')
  end
end
