require 'test_helper'

feature 'User Applications Page' do
  def setup
    @applicant = make_user
    @event = make_event(name: 'Applicants event')
    @application = make_application(event: @event, applicant_id: @applicant.id)
  end

  test 'shows a section to Your applications where the users applications are displayed' do
    sign_in_as(@applicant)

    visit root_path

    click_link 'Your applications'

    assert page.text.include?('Applicants event')
    assert_select 'h2', 'Your applications'
  end
end
