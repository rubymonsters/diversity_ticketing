require 'test_helper'

feature 'Event Overview' do
  def setup
    @user = make_user
    @event = make_event(approved: true)
  end

  test 'shows a link to Apply if the user didnt applied or created a draft to the event' do
    sign_in_as_user

    visit events_path

    click_button("Apply")

    assert_equal current_path, new_event_application_path(@event.id)
  end

  test 'shows a link to Your Draft if the user already created a draft for the event' do
    application = make_application(@event, applicant_id: @user.id, submitted: false)

    sign_in_as_user

    visit events_path

    assert_not page.has_content?("Apply")

    click_link("Your Draft")

    assert_equal current_path, event_application_path(@event.id, application.id)
  end

  test 'shows a link to Your Application if the user already submitted an application for the event' do
    application = make_application(@event, applicant_id: @user.id, submitted: true)

    sign_in_as_user

    visit events_path

    assert_not page.has_content?("Apply")

    page.all('a', text:"Your Application")[1].click

    assert_equal current_path, event_application_path(@event.id, application.id)
  end
end
