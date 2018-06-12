require 'test_helper'

feature 'User Applications Page' do
  def setup
    @user = make_user
    @event = make_event(name: 'Applicants event')
    @event2 = make_event(name: 'Second Event')
    @application = make_application(@event, applicant_id: @user.id)
    @draft = make_draft(@event2, applicant_id: @user.id)
  end

  test 'shows a section in Your applications where the users applications and drafts are displayed' do
    sign_in_as_user

    visit root_path

    click_link 'Your applications'

    assert_equal current_path, user_applications_path(@user.id)

    page.assert_selector('h2', text: "Submitted")
    page.assert_selector('h2', text: "Drafts")
    page.assert_selector('a', text: @event.name)
    page.assert_selector('a', text: @event2.name)
    assert_equal event_path(@event.id), page.find_link(@event.name)[:href]
    assert_equal event_path(@event2.id), page.find_link(@event2.name)[:href]
    assert_equal event_application_path(@event.id, @application.id), page.all('a', text:'Your application')[0][:href]
    assert_equal event_application_path(@event2.id, @draft.id), page.all('a', text:'Your application')[1][:href]
  end
end
