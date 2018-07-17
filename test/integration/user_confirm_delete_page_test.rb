require 'test_helper'

feature 'User Confirm Delete Page' do
  def setup
    @user = make_user
  end

  test 'that back- and delete-links are being shown correctly' do
    sign_in_as_user

    visit root_path

    assert page.text.include?("#{@user.name}")

    page.find("#dropdown-btn").click
    click_link 'Account settings'

    page.fill_in 'user_password', with: @user.password
    click_link 'Delete account'

    assert page.text.include?("Are you sure?")
    assert page.has_link?('No, go back!')
    assert page.has_link?('Yes, proceed!')
  end
end
