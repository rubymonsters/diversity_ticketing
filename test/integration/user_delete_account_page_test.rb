require 'test_helper'

feature 'User Delete Account Page' do
  def setup
    @user = make_user
  end

  test 'that back- and delete-links are being shown correctly' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("#{@user.name}")

    page.find("#dropdown-btn").click
    click_link 'Account Settings'

    page.fill_in 'user_password', with: @user.password
    click_button 'Delete Account'

    assert page.text.include?("Are you sure?")
    assert page.has_link?('No, go back!')
    assert page.has_link?('Yes, delete account!')
  end

  test 'that admins can not access the delete account page of other users' do
    admin = make_admin
    sign_in_as_admin

    visit delete_account_path(@user)

    assert page.text.include?("We're sorry. You don't have permission to access this page.")
  end

  test 'that no user can access the delete account page of other users' do
    user2 = make_user(email: 'b@user.com')

    visit '/'
    click_link 'Sign in'

    fill_in 'Email', with: 'b@user.com'
    fill_in 'Password', with: 'awesome_password'
    click_button 'Sign in'

    visit delete_account_path(@user)

    assert page.text.include?("We're sorry. You don't have permission to access this page.")
  end

  test 'that users can only access the delete account page via "Delete Account"-Button on their settings page' do
    sign_in_as_user

    visit delete_account_path(@user)

    assert page.text.include?("We're sorry. You don't have permission to access this page.")
  end
end
