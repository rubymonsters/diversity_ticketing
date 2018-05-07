require 'test_helper'

feature 'New Application' do
  def setup
    @admin = make_admin
    @user = make_user
    @event = make_event(organizer_id: @admin.id, approved: true)
  end

  test 'creates an application for logged-out user' do
    visit event_path(@event.id)

    click_button "Apply"

    page.fill_in 'application_name', with: @user.name
    page.fill_in 'application_email', with: @user.email
    page.fill_in 'application_email_confirmation', with: @user.email
    page.fill_in 'application_attendee_info_1', with: 'I want to learn how to code'
    page.fill_in 'application_attendee_info_2', with: 'I am an underrepresented minority'
    page.check 'application[terms_and_conditions]'

    click_button "Submit Application"
    
    assert page.text.include?("You have successfully applied for #{@event.name}")
  end

  test 'autofills the application with information from the users profile' do
    sign_in_as_user

    visit event_path(@event.id)

    click_button "Apply"

    page.fill_in 'application_attendee_info_1', with: 'I want to learn how to code'
    page.fill_in 'application_attendee_info_2', with: 'I am an underrepresented minority'
    page.fill_in 'application_email_confirmation', with: @user.email
    page.check 'application[terms_and_conditions]'

    click_button "Submit Application"

    assert page.text.include?("You have successfully applied for #{@event.name}")
  end

  test 'raises an error if a field was not included properly' do
    sign_in_as_user

    visit event_path(@event.id)

    click_button "Apply"

    click_button "Submit Application"

    assert page.text.include?("5 errors stopped this application from being saved")
  end

  test 'entered information has precedence over user-information if the user is signed in' do
    sign_in_as_user

    visit event_path(@event.id)

    click_button "Apply"

    page.fill_in 'application_name', with: "New name"
    page.fill_in 'application_attendee_info_1', with: 'I want to learn how to code'
    page.fill_in 'application_attendee_info_2', with: 'I am an underrepresented minority'
    page.fill_in 'application_email_confirmation', with: @user.email
    page.check 'application[terms_and_conditions]'

    click_button "Submit Application"

    assert page.text.include?("You have successfully applied for #{@event.name}")

    assert_equal "New name", Application.find_by(applicant_id: @user.id).name
    assert_equal "Awesome name", @user.name
  end

  test 'a user is able to save an application as a draft before submitting it' do
    sign_in_as_user
    visit event_path(@event.id)

    click_button "Apply"

    page.fill_in 'application_name', with: "New name"
    page.fill_in 'application_attendee_info_1', with: 'I want to learn how to code'
    page.fill_in 'application_attendee_info_2', with: 'I am an underrepresented minority'
    page.fill_in 'application_email_confirmation', with: @user.email
    page.check 'application[terms_and_conditions]'

    click_button "Save as a Draft"

    assert_equal @event.applications.last.email, @user.email
    assert_equal Application.last.submitted, false
  end

  test 'shows Save as Draft Button only to logged in users' do
    visit event_path(@event.id)

    click_button "Apply"

    assert_not page.has_content?('Save as a Draft')
  end

  test 'shows sign-in link to not logged in users to allow them to use their credentials for this application' do
    visit event_path(@event.id)

    click_button "Apply"

    assert page.has_content?('Would you like to Sign In to use your profile information and save this application?')
  end

  test 'does not show sign-in link to logged in users inside the application' do
    sign_in_as_user

    visit event_path(@event.id)

    click_button "Apply"

    assert_not page.has_content?('Would you like to Sign In to use your profile information and save this application?')
  end

  test 'shows an Your Application button if the user already submitted an application for the event' do
    application = make_application(@event, applicant_id: @user.id, submitted: true)

    sign_in_as_user

    visit event_path(@event.id)

    assert_not page.has_content?("Apply")

    click_button "Your Application"

    assert_equal current_path, event_application_path(@event.id, application.id)
  end

  test 'shows an Your Draft button if the user already saved a draft for the event' do
    application = make_application(@event, applicant_id: @user.id, submitted: false)

    sign_in_as_user

    visit event_path(@event.id)

    assert_not page.has_content?("Apply")

    click_button "Your Draft"

    assert_equal current_path, event_application_path(@event.id, application.id)
  end
end
