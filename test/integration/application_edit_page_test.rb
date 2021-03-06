require 'test_helper'

feature 'Application Edit' do
  def setup
    @user = make_user
    @event = make_event(name: 'The Event', approved: true)
    @event2 = make_event(name: 'Second Event', approved: true)
    @application = make_application(
                  @event,
                  applicant_id: @user.id,
                  attendee_info_1: 'I would like to learn Ruby',
                  attendee_info_2: 'I can not afford the ticket'
                )
  end

  test 'allows the user to edit their own submitted application' do
    sign_in_as_user

    visit edit_event_application_path(@event.id, @application.id)

    assert page.has_content?("Why do you want to attend #{@event.name} and what especially do you look forward to learning?")
    assert page.has_content?(@application.attendee_info_1)
    assert page.has_content?("Please share with us why you're applying for a diversity ticket.")
    assert page.has_content?(@application.attendee_info_2)
    assert page.has_content?("Name")
    assert page.has_content?("Email")
    assert page.has_content?("Back")
    assert page.has_selector?("input[type=submit][value='Apply changes']")
  end

  test 'does not allow a user to edit other users application' do
    other_user = make_user(email: "other@user.de")
    other_application = make_application(@event, applicant_id: other_user.id)
    sign_in_as_user

    visit edit_event_application_path(@event.id, other_application.id)

    assert_equal root_path, current_path
  end

  test 'does not allow applicant to edit application after the deadline has passed' do
    @event.update_attributes(deadline: 1.day.ago)
    sign_in_as_user

    visit edit_event_application_path(@event.id, @application.id)

    assert page.has_content?("You cannot edit your application as the #{@event.name} deadline has already passed")
  end

  test 'shows correct flash message after submitting changes to an application' do
    sign_in_as_user

    visit edit_event_application_path(@event.id, @application.id)

    fill_in 'application[attendee_info_1]', with: "I made some changes."
    fill_in 'application[email_confirmation]', with: @user.email
    check 'application[terms_and_conditions]'

    click_button('Apply changes')

    assert page.has_content?("You have successfully updated your application for #{@event.name}.")
  end
end
