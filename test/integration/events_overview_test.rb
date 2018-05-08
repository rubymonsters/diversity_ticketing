require 'test_helper'

feature 'Event Overview' do
  def setup
    @user = make_user
    @event = make_event(approved: true)
  end

  test 'shows a link to Apply if the user did not apply or create a draft for the event' do
    sign_in_as_user

    visit events_path

    click_button("Apply")

    assert_equal current_path, new_event_application_path(@event.id)
  end

  test 'shows a link to Your Draft if the user already created a draft for the event' do
    application = make_draft(@event, applicant_id: @user.id)

    sign_in_as_user

    visit events_path

    assert_not page.has_content?("Apply")

    click_button("Your Draft")

    assert_equal event_application_path(@event.id, application.id), current_path
  end

  test 'shows a link to Your Application if the user already submitted an application for the event' do
    application = make_draft(@event, applicant_id: @user.id)

    sign_in_as_user

    visit events_path

    assert_not page.has_content?("Apply")

    page.all('a', text:"Your Application")
    click_button("Your Application")

    assert_equal event_application_path(@event.id, application.id), current_path
  end
end
