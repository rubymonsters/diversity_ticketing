require 'test_helper'

feature 'Admin Events' do
  scenario 'Approve event' do
    make_admin
    event = make_event(name: "The Event")
    TwitterWorker.expects(:announce_event).with(event).once

    visit '/'
    click_link 'Sign in'

    fill_in 'Email', with: 'admin@woo.hoo'
    fill_in 'Password', with: 'awesome_password'
    click_button 'Sign in'

    click_link 'Admin'

    within(first('.box', text: 'Unapproved Events')) do
      assert page.text.include?('The Event')
      click_link 'approve'
    end

    within(first('.box', text: 'Unapproved Events')) do
      refute page.text.include?('The Event')
    end

    within(first('.box', text: 'Approved Events')) do
      assert page.text.include?('The Event')
    end
  end
end
