require 'test_helper'

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

    assert page.has_content?('2 applications currently')
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

    page.assert_selector('i.fa-check')
    page.assert_selector('i.fa-times')
  end

  test 'shows a list of pending applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Pending (2)")
  end

  test 'shows a list of approved applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved (1)")
  end

  test 'shows a list of rejected applications' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Rejected (0)")
  end

  test 'changes application status after click on approved link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved (1)")
    assert page.has_content?("Pending (2)")

    click_link('.fa-check').last

    assert_equal "Paul's application has been approved!", flash[:notice]

    assert page.has_content?("Approved (2)")
    assert page.has_content?("Pending (1)")
  end

  test 'changes application status after click on reject link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Pending (2)")
    assert page.has_content?("Rejected (0)")

    click_link('.fa-times').first

    assert_equal "Peter's application has been rejected", flash[:info]

    assert page.has_content?("Pending (1)")
    assert page.has_content?("Rejected (1)")
  end

  test 'changes application status back to pending after clicking on undo link' do
    sign_in_as_admin

    visit admin_event_path(@event.id)

    assert page.has_content?("Approved (1)")
    assert page.has_content?("Pending (2)")

    click_link('Undo')

    assert_equal "Lara's application has been changed to pending", flash[:info]

    assert page.has_content?("Approved (0)")
    assert page.has_content?("Pending (3)")
  end
end
