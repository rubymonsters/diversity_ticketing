require 'test_helper'

feature 'Admin Events' do
  before do
    make_application_process_options_handler
  end

  scenario 'Approve and unapprove event' do
    click_link 'Admin'

    within(approved_events_box) do
      refute page.text.include?('The event')
    end

    within(unapproved_events_box) do
      assert page.text.include?('The event')
      click_button 'approve'
    end

    within(unapproved_events_box) do
      refute page.text.include?('The event')
    end

    within(approved_events_box) do
      assert page.text.include?('The event')
      click_link 'approve'
    end

    within(approved_events_box) do
      refute page.text.include?('The event')
    end

    within(unapproved_events_box) do
      assert page.text.include?('The event')
    end
  end

  before do
    make_admin
    sign_in_as_admin
    event = make_event(name: 'The event', approved: false)
  end

  def unapproved_events_box
    first('.box', text: 'Unapproved events')
  end

  def approved_events_box
    first('.box', text: 'Approved events')
  end
end
