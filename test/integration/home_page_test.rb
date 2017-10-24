require 'test_helper'

feature 'Home Page' do
  scenario 'Visit home page' do
    visit root_path
    page.must_have_content 'We help events reach a more diverse audience. And we help you to find these events.'
    click_link 'Attendees'
    page.must_have_content 'We currently have no events lined up'
  end
end
