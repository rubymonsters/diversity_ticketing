require 'test_helper'

feature 'User Sign In' do
  def setup
    @user = make_user
    @admin = make_admin
  end

  test 'redirects the user to the previous allowed page they were browing' do
    visit '/events'

    click_link 'Sign in'

    fill_in 'Email', with: 'awesome@example.org'
    fill_in 'Password', with: 'awesome_password'
    click_button 'Sign in'

    assert_equal current_path, events_path
  end

  test 'redirects the user root if they previous page is not allowed for them' do
    sign_in_as_admin

    visit admin_events_path

    click_link 'Sign out'

    fill_in 'Email', with: 'awesome@example.org'
    fill_in 'Password', with: 'awesome_password'
    click_button 'Sign in'

    assert_equal current_path, root_path
  end

  test 'sign-in page shows link to sign up with a "Create your Account"-Button' do
    visit sign_in_path

    assert page.has_content?("Create your Account")
    click_link "Create your Account"

    assert page.has_content?("Sign up")
  end

  test 'sign-up page shows link to sign in with a "Sign in here"-Button' do
    visit sign_up_path

    assert page.has_content?("Already registered?")
    click_link "Sign in here"

    assert page.has_content?("New to Diversity Tickets?")
  end

end
