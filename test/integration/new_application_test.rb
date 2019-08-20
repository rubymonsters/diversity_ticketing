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

    click_link "Continue as guest"

    page.fill_in 'application_name', with: @user.name
    page.fill_in 'application_email', with: @user.email
    page.fill_in 'application_email_confirmation', with: @user.email
    page.fill_in 'application_attendee_info_1', with: 'I want to learn how to code'
    page.fill_in 'application_attendee_info_2', with: 'I am an underrepresented minority'
    page.check 'application[terms_and_conditions]'

    click_button "Submit application"

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

    click_button "Submit application"

    assert page.text.include?("You have successfully applied for #{@event.name}")
  end

  test 'raises an error if a field was not included properly' do
    sign_in_as_user

    visit event_path(@event.id)

    click_button "Apply"

    click_button "Submit application"

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

    click_button "Submit application"

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

    click_button "Save as a draft"

    assert_equal @event.applications.last.email, @user.email
    assert_equal Application.last.submitted, false
  end

  test 'shows Save as Draft Button only to logged in users' do
    visit event_path(@event.id)

    click_button "Apply"

    assert_not page.has_content?('Save as a draft')
  end

  test 'shows continue_as_guest? page to not logged in users' do
    visit event_path(@event.id)

    click_button "Apply"

    assert page.has_content?('How would you like to apply?')
  end

  test 'shows sign-in link to not logged in users inside application to still allow to sign-in after continuing as guest' do
    visit event_path(@event.id)

    click_button "Apply"

    assert page.has_content?('How would you like to apply?')

    click_link "Continue as guest"

    assert page.has_content?('Would you like to sign in to use your profile information and save this application?')
  end

  test 'does not show sign-in link to logged in users inside the application' do
    sign_in_as_user

    visit event_path(@event.id)

    click_button "Apply"

    assert_not page.has_content?('Would you like to Sign in to use your profile information and save this application?')
  end

  test 'shows an Your Application button if the user already submitted an application for the event' do
    application = make_application(@event, applicant_id: @user.id)
    sign_in_as_user

    visit event_path(@event.id)

    assert_not page.has_content?("Apply")

    click_button "Your application"

    assert_equal current_path, event_application_path(@event.id, application.id)
  end

  test 'shows an Your draft button if the user already saved a draft for the event' do
    draft = make_draft(@event, applicant_id: @user.id)
    sign_in_as_user

    visit event_path(@event.id)

    assert_not page.has_content?("Apply")

    click_button "Your draft"

    assert_equal current_path, event_application_path(@event.id, draft.id)
  end

  test 'shows correct flash message for creating a draft' do
    sign_in_as_user

    visit event_path(@event.id)

    click_button "Apply"

    assert page.has_button?("Save as a draft")

    click_button "Save as a draft"

    assert page.has_content?("You have successfully saved an application draft for #{@event.name}.")
  end

  test 'redirects to users application overview after sign_in via continue_as_guest? if an application already exists' do
    @application = make_application(@event, application_params = {
      name: @user.name,
      email: @user.email,
      email_confirmation: @user.email,
      applicant_id: @user.id
      })

    visit event_path(@event.id)

    click_button "Apply"

    click_link "Sign me in"

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Sign in'

    assert_equal current_path, user_applications_path(@user.id)
  end

  test 'redirects to users application overview after sign_in via continue_as_guest? if a draft already exists' do
    @draft = make_draft(@event, application_params = {
      name: @user.name,
      email: @user.email,
      email_confirmation: @user.email,
      applicant_id: @user.id
      })

    visit event_path(@event.id)

    click_button "Apply"

    click_link "Sign me in"

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Sign in'

    assert_equal current_path, user_applications_path(@user.id)
  end
end
