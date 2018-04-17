require 'test_helper'

feature 'Applicants User Account' do
  def setup
    @applicant = make_user
    @event = make_event(name: 'Applicants event')
    @application = make_application(applicant_id: @applicant.id, event_id: @event.id)
  end

  test 'shows a Your applications section where the applications are displayed' do
    sign_in_as(@applicant)

    visit root_path

    click_link 'Your applications'

    visit events_path

    assert page.text.include?('Applicants event')
    assert_select 'h2', 'Your applications'
  end
end
