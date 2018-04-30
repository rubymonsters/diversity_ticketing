require 'test_helper'

feature 'User Applications Page' do
  def setup
    @user = make_user
    @event = make_event(name: 'Applicants event')
    @application = make_application(@event, applicant_id: @user.id, submitted: true)
    @draft = make_application(@event, applicant_id: @user.id)
  end

  test 'shows a section in Your Applications where the users applications are displayed' do
    sign_in_as_user

    visit root_path

    click_link 'Your Events'

    assert_equal current_path, user_path(@user.id)

    assert page.find_link(@event.name)
    assert_equal event_path(@event.id), page.find_link(@event.name)[:href]
    assert page.find_link('Your Application')
    assert_equal event_application_path(@event.id, @application.id), page.find_link('Your Application')[:href]
  end
end
