require 'test_helper'

feature 'New Application' do
  def setup
    @admin = make_admin
    @user = make_user
    @event = make_event(organizer_id: @admin.id, approved: true)
  end

  test 'creates an application after an unlogged user introduced their information' do
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
    page.check 'application[terms_and_conditions]'

    click_button "Submit Application"

    assert page.text.include?("You have successfully applied for #{@event.name}")
  end
end