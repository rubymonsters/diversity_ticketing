require 'test_helper'

feature 'Application draft' do
  def setup
    @user = make_user
    @admin = make_admin
    @event = make_event(name: 'The Event', approved: true)
    @draft = make_application(
                  @event,
                  applicant_id: @user.id,
                  attendee_info_1: 'I would like to learn Ruby',
                  attendee_info_2: 'I can not afford the ticket',
                  submitted: false
                )
  end


  test 'does not show link to Submit the application if user is an admin' do
    sign_in_as_admin

    visit event_application_path(@event.id, @draft.id)

    assert_not page.has_content?('Submit Application')
  end

  test 'shows link to Submit if user is an applicant and event-deadline has not passed' do
    sign_in_as_user

    visit event_application_path(@event.id, @draft.id)

    assert page.has_content?('Submit Application')
  end

  test 'does not show link to Submit if user is an applicant and event-deadline has passed' do
    @event.update_attributes(deadline: 1.day.ago)
    sign_in_as_user

    visit event_application_path(@event.id, @draft.id)

    assert_not page.has_content?('Submit Application')
  end

  test 'sets the status of the application to submitted after clicking Submit' do
    sign_in_as_user

    visit event_application_path(@event.id, @draft.id)

    click_link('Submit Application')

    @draft.reload

    assert_equal true, @draft.submitted
  end

  test 'shows link to Delete if application is a draft and deadline-has passed' do
    @event.update_attributes(deadline: 1.day.ago)
    sign_in_as_user

    visit event_application_path(@event.id, @draft.id)

    assert page.has_content?('Delete')
  end
end
