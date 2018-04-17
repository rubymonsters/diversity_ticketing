require 'test_helper'

feature 'User Applications Page' do
  def setup
    @applicant = make_user
    @event = make_event(name: 'Applicants event')
    @application = make_application(@event, applicant_id: @applicant.id)
  end

  test 'shows a section to Your applications where the users applications are displayed' do
    sign_in_as_user

    visit root_path

    click_link 'Your Applications'

    assert page.text.include?('Applicants event')
    page.must_have_content 'Your applications'
  end
end
