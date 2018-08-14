require 'test_helper'

feature 'User Settings Page' do
  def setup
    @user = make_user
  end

  test 'that name input field is present in settings page and updates users name' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("Your account")

    page.find("#dropdown-btn").click

    click_link 'Account settings'

    assert page.text.include?('Account settings')
    page.must_have_selector("form input[name='user[name]']")
    page.fill_in 'user_name', with: 'My Name'
    page.fill_in 'user_password', with: @user.password

    click_button 'Save changes'

    assert page.text.include?('You have successfully updated your user data.')

    @user.reload

    assert_equal 'My Name', @user.name
  end


  test 'that country input field is present in settings page and updates users country' do
    sign_in_as_user

    visit root_path

    click_link 'Account settings'

    page.must_have_selector("select[name='user[country]']")
    page.select 'Spain', from: :user_country
    page.fill_in 'user_password', with: @user.password

    click_button 'Save changes'

    assert page.text.include?('You have successfully updated your user data.')

    @user.reload

    assert_equal 'Spain', @user.country
  end

  test 'that Delete Account redirects to confirm delete page' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("Your account")

    page.find("#dropdown-btn").click
    click_link 'Account settings'

    click_link 'Delete account'

    assert page.text.include?("Are you sure?")
  end

  test 'that country_email_notifications checkbox is present in settings page and updates users preferences' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("Your account")

    page.find("#dropdown-btn").click
    click_link 'Account settings'

    page.must_have_selector("input[name='user[country_email_notifications]']")
    assert_equal false, @user.country_email_notifications
    page.check 'user[country_email_notifications]'
    page.fill_in 'user_password', with: @user.password

    click_button 'Save changes'

    assert page.text.include?('You have successfully updated your user data.')

    @user.reload

    assert_equal true, @user.country_email_notifications
  end

  test 'that password validation works' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("Your account")

    page.find("#dropdown-btn").click
    click_link 'Account settings'

    page.fill_in 'user_name', with: 'New Name'

    click_button 'Save changes'

    assert page.text.include?("You have successfully updated your user data.")

    page.fill_in 'user_new_password', with: 'something'

    click_button 'Save changes'

    assert page.text.include?("Password is a mandatory field")

    page.fill_in 'user_new_password', with: 'something'

    page.fill_in 'user_password', with: 'wrong_password'

    click_button 'Save changes'

    assert page.text.include?("Incorrect password")

    page.fill_in 'user_new_password', with: 'something'

    page.fill_in 'user_password', with: @user.password

    click_button 'Save changes'

    assert page.text.include?("You have successfully updated your user data.")
  end
end
