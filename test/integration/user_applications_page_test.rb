require 'test_helper'

feature 'User Applications Page' do
  def setup
    @applicant = make_user
    @event = make_event(name: 'Applicants event')
    @application = make_application(@event, applicant_id: @applicant.id, attendee_info_1: 'I want to learn to code')
  end

  test 'shows a section to Your applications where the users applications are displayed' do
    sign_in_as_user

    visit root_path

    click_link 'Your Applications'

    assert page.text.include?('Applicants event')
    page.must_have_content 'Your applications'
  end

  test 'shows a link to Your application where the application for the event is displayed' do
    sign_in_as_user

    visit root_path

    click_link 'Your Applications'

    assert page.text.include?('Your application')

    click_link 'Your application'

    assert page.text.include?('I want to learn to code')
    assert_not page.text.include?('Delete this application')
    assert page.text.include?('Show Event Details')

    click_link 'Show Event Details'

    assert page.text.include?(@event.name)
  end
end
