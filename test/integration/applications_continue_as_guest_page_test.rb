require 'test_helper'

feature 'Application Edit' do
  def setup
    @user = make_user
    @event = make_event(name: 'The Event', approved: true)
  end

  test 'that buttons for "Continue as guest", "Sign me in" and "Create an account" are present' do
    visit events_path

    click_button('Apply')

    assert_current_path continue_as_guest_path(@event.id)

    assert page.has_link?("Continue as guest")
    assert page.has_link?("Sign me in")
    assert page.has_link?("Create an account")
  end

  test 'successful redirect to new application form after clicking "Continue as guest"' do
    visit events_path

    click_button('Apply')

    click_link 'Continue as guest'

    assert_current_path new_event_application_path(@event.id, guest: true)
  end

  test 'successful redirect to new application form after clicking "Sign me in"' do
    visit events_path

    click_button('Apply')

    click_link 'Sign me in'

    assert_current_path sign_in_path

    fill_in 'Email', with: 'awesome@example.org'
    fill_in 'Password', with: 'awesome_password'
    click_button 'Sign in'

    assert_current_path new_event_application_path(@event.id)
  end

  test 'successful redirect to new application form after clicking "Create an account"' do
    visit events_path

    click_button('Apply')

    click_link 'Create an account'

    assert_current_path sign_up_event_path(@event.id)

    fill_in 'Email', with: 'new@example.org'
    fill_in 'Password', with: 'new_password'
    check("I agree with the privacy policy of Diversity Tickets")
    click_button 'Create your account'

    assert_current_path new_event_application_path(event_id: @event.id)
  end
end
