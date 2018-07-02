require 'test_helper'

feature 'User Delete Account Page' do
  def setup
    @user = make_user
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

  test 'that users can only access the delete account page via "Yes, proceed!"-Button on their confirm_delete page' do
    sign_in_as_user

    visit delete_account_path(@user)

    assert_equal current_path, confirm_delete_path(@user)
  end
end
