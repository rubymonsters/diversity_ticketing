require 'test_helper'

feature 'Admin Events' do
  scenario 'Approve and unapprove event' do
    click_link 'Admin'

    within(approved_events_box) do
      refute page.text.include?('The Event')
    end

    within(unapproved_events_box) do
      assert page.text.include?('The Event')
      click_link 'approve'
    end

    within(unapproved_events_box) do
      refute page.text.include?('The Event')
    end

    within(approved_events_box) do
      assert page.text.include?('The Event')
      click_link 'approve'
    end

    within(approved_events_box) do
      refute page.text.include?('The Event')
    end

    within(unapproved_events_box) do
      assert page.text.include?('The Event')
    end
  end

  before do
    make_admin
    sign_in_as_admin
    event = make_event(name: 'The Event', approved: false)
    TwitterWorker.expects(:announce_event).with(event).once
  end

  def unapproved_events_box
    first('.box', text: 'Unapproved Events')
  end

  def approved_events_box
    first('.box', text: 'Approved Events')
  end
end
