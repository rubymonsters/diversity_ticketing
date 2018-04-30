require 'test_helper'

feature 'Admin Event Details' do

  def setup
    @admin = make_admin
    @event = make_event
    @application_1 = make_application(@event, submitted: true)
    @application_2 = make_application(@event, submitted: true)
    @application_draft = make_application(@event, submitted: false)
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
end
