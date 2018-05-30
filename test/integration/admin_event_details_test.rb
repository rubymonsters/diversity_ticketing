require 'test_helper'
include ApplicationHelper

feature 'Admin Event Details' do

  def setup
    @admin = make_admin
    @event = make_event
    @application_1 = make_application(@event, name: 'Peter', status: 'pending')
    @application_2 = make_application(@event, name: 'Paul', status: 'pending')
    @application_3 = make_application(@event, name: 'Lara', status: 'approved')
    @application_draft = make_draft(@event, name: 'Mary')
  end

  test 'shows number of submitted applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?('3 applications currently')
  end

  test 'shows number of application drafts' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?('1 draft currently')
  end

  test 'does not show draft applications details on event details page for admin' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert_not page.has_content?('Mary')

  end

  test 'shows submitted applications on event details page for admin' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?('Peter')
    assert page.has_content?('Paul')
  end

  test 'shows icons for approve and reject links' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    page.assert_selector('.approve-application-icon')
    page.assert_selector('.reject-application-icon')
  end

  test 'shows a list of pending applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Pending Applications (2)")
  end

  test 'shows a list of approved applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved Applications (1)")
  end

  test 'shows a list of rejected applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Rejected Applications (0)")
  end

  test 'changes application status after click on approved link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved Applications (1)")
    assert page.has_content?("Pending Applications (2)")

    page.first('a.icon.tooltip').click

    assert page.has_content?("Peter's application has been approved!")

    assert page.has_content?("Approved Applications (2)")
    assert page.has_content?("Pending Applications (1)")
  end

  test 'changes application status after click on reject link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Pending Applications (2)")
    assert page.has_content?("Rejected Applications (0)")

    page.all('a.icon.tooltip')[1].click

    assert page.has_content?("Peter's application has been rejected")

    assert page.has_content?("Pending Applications (1)")
    assert page.has_content?("Rejected Applications (1)")
  end

  test 'changes application status back to pending after clicking on revert link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved Applications (1)")
    assert page.has_content?("Pending Applications (2)")

    click_link('Revert')

    assert page.has_content?("Lara's application has been changed to pending")

    assert page.has_content?("Approved Applications (0)")
    assert page.has_content?("Pending Applications (3)")
  end

  test 'shows Approve event Button if event has not been approved' do
    sign_in_as_admin
    @event.update_attributes(deadline: 2.weeks.from_now)

    visit admin_event_path(@event.id)

    assert page.has_content?("Approve event")

    click_link("Approve event")

    assert page.has_content?("#{@event.name} has been approved!")
  end
end
