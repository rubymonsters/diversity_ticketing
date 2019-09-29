require 'test_helper'
include ApplicationHelper

feature 'Admin Event Details' do

  def setup
    make_application_process_options_handler
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

    page.assert_selector('.approve-application')
    page.assert_selector('.reject-application')
  end

  test 'shows a list of pending applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Pending applications (2)")
  end

  test 'shows a list of approved applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved applications (1)")
  end

  test 'shows a list of rejected applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Rejected applications (0)")
  end

  test 'changes application status after click on approved link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved applications (1)")
    assert page.has_content?("Pending applications (2)")

    page.first('a.btn.btn-save.approve-application').click

    assert page.has_content?("Peter's application has been approved!")

    assert page.has_content?("Approved applications (2)")
    assert page.has_content?("Pending applications (1)")
  end

  test 'changes application status after click on reject link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Pending applications (2)")
    assert page.has_content?("Rejected applications (0)")

    page.first('a.btn.btn-external.reject-application').click

    assert page.has_content?("Peter's application has been rejected")

    assert page.has_content?("Pending applications (1)")
    assert page.has_content?("Rejected applications (1)")
  end

  test 'changes application status back to pending after clicking on revert link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved applications (1)")
    assert page.has_content?("Pending applications (2)")

    page.first('a.btn.btn-edit.revert-application').click

    assert page.has_content?("Lara's application has been changed to pending")

    assert page.has_content?("Approved applications (0)")
    assert page.has_content?("Pending applications (3)")
  end

  test 'shows Approve event Button if event has not been approved' do
    sign_in_as_admin
    @event.update_attributes(deadline: 2.weeks.from_now)

    visit admin_event_path(@event.id)

    assert page.has_selector?("input[type=submit][value='Approve event']")
    click_button("Approve event")

    assert page.has_content?("#{@event.name} has been approved!")
  end

  test 'shows correct number of approved tickets' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Distributed tickets: 1")
    @event.reload
    assert_equal 1, @event.approved_tickets

    page.first('a.btn.btn-edit.revert-application').click
    @event.reload
    assert_equal 0, @event.approved_tickets
    assert page.has_content?("Distributed tickets: 0")

    page.first('a.btn.btn-save.approve-application').click
    @event.reload
    assert_equal 1, @event.approved_tickets
    assert page.has_content?("Distributed tickets: 1")

    page.first('a.btn.btn-save.approve-application').click
    @event.reload
    assert_equal 2, @event.approved_tickets
    assert page.has_content?("Distributed tickets: 2")
  end
end
