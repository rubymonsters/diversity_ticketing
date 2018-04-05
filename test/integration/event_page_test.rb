require 'test_helper'

feature 'Event' do
  before do
    make_user
    sign_in_as_user
    event = make_event(name: 'The Event', approved: true)
  end

  scenario 'Events are displayed in the events page' do
    visit root_path
    click_link 'Events'

    assert page.text.include?('The Event')
    assert page.body.include?('event-default')
  end

  before do
    event = make_event(name: 'The Event', approved: true, logo: 'logo-image')
  end

  scenario 'Events are displayed in the events page' do
    visit root_path
    click_link 'Events'

    assert page.text.include?('The Event')
    assert page.body.include?('logo-image')

    pp page.body
  end

end
