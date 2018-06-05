require 'test_helper'

feature 'User Settings Page' do
  def setup
    @user = make_user
  end

  test 'that name input field is present in settings page and updates user name' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("#{@user.name}")

    page.find("#dropdown-btn").click
    click_link 'Account Settings'

    assert page.text.include?('Edit your credentials')
    page.must_have_selector("form input[name='user[name]']")
    page.fill_in 'user_name', with: 'My Name'
    page.fill_in 'user_password', with: @user.password

    click_button 'Update User'

    assert page.text.include?('You have successfully updated your user data.')

    @user.reload

    assert_equal 'My Name', @user.name
  end

  test 'that password is required for Delete Account' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("#{@user.name}")

    page.find("#dropdown-btn").click
    click_link 'Account Settings'

    assert page.has_button?('Delete Account')

    click_button 'Delete Account'
    assert page.text.include?('Password is a mandatory field')
  end

  test 'that password validation works and Delete Account redirects to delete account page' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("#{@user.name}")

    page.find("#dropdown-btn").click
    click_link 'Account Settings'

    page.fill_in 'user_password', with: @user.password
    click_button 'Delete Account'

    assert page.text.include?("Are you sure?")
  end
end
