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

end
