require 'test_helper'

feature 'User Applications Page' do
  def setup
    @user = make_user
    @event = make_event(name: 'Applicants event')
    @application = make_application(@event, applicant_id: @user.id, submitted: true)
    @draft = make_application(@event, applicant_id: @user.id, submitted: false)
  end

  test 'shows a section in Your Applications where the users applications and drafts are displayed' do
    sign_in_as_user

    visit root_path

    click_link 'Your Applications'

    assert_equal current_path, user_applications_path(@user.id)

    page.assert_selector('h2', text: "Submitted")
    page.assert_selector('h2', text: "Drafts")
    page.assert_selector('a', text: @event.name, count: 2)
    assert_equal event_path(@event.id), page.find_link(@event.name).first[:href]
    assert_equal event_application_path(@event.id, @application.id), page.find_link('Your Application')[:href]
    assert_equal event_application_path(@event.id, @draft.id), page.find_link('Your Draft')[:href]
  end
end
