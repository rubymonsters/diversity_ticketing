require 'test_helper'

feature 'User Settings Page' do
  def setup
    @user = make_user
  end

  test 'that name input field is present in settings page and updates users name' do
    sign_in_as_user

    visit root_path

    click_link 'Account Settings'

    assert page.text.include?('Profile settings')
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

    click_link 'Account Settings'

    page.must_have_selector("select[name='user[country]']")
    page.select 'Spain', from: :user_country
    page.fill_in 'user_password', with: @user.password

    click_button 'Save changes'

    assert page.text.include?('You have successfully updated your user data.')

    @user.reload

    assert_equal 'Spain', @user.country
  end

  test 'that country_email_notifications checkbox is present in settings page and updates users preferences' do
    sign_in_as_user

    visit root_path

    click_link 'Account Settings'

    page.must_have_selector("input[name='user[country_email_notifications]']")
    assert_equal false, @user.country_email_notifications
    page.check 'user[country_email_notifications]'
    page.fill_in 'user_password', with: @user.password

    click_button 'Save changes'

    assert page.text.include?('You have successfully updated your user data.')

    @user.reload

    assert_equal true, @user.country_email_notifications
  end
end
