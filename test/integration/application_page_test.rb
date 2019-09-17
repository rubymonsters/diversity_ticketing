require 'test_helper'

feature 'Application Page' do
  def setup
    @user = make_user
    @admin = make_admin
    @event = make_event(name: 'The Event', approved: true)
    @application = make_application(
                  @event,
                  applicant_id: @user.id,
                  attendee_info_1: 'I would like to learn Ruby',
                  attendee_info_2: 'I can not afford the ticket'
                )
    @admin_application = make_application(
                  @event,
                  applicant_id: @admin.id,
                  attendee_info_1: 'I would like to learn Ruby as admin',
                  attendee_info_2: 'I can not afford the ticket as admin'
                )
  end

  test 'shows Your applications in the breadcrumb if the user is not an admin' do
    sign_in_as_user

    visit user_applications_path(@user.id)

    click_link 'Your application'

    assert_equal current_path, event_application_path(@event.id, @application.id)

    assert page.has_content?('Your application')

    assert_equal 2, page.all("a[href='/en/users/#{@user.id}/applications']").count
  end

  test 'shows link to delete this application if user is an admin' do
    sign_in_as_admin

    visit event_application_path(@event.id, @application.id)

    assert page.has_content?('Delete')
  end

  test 'shows link to Delete if user is an applicant and event-deadline has not passed' do
    sign_in_as_user

    visit event_application_path(@event.id, @application.id)

    assert page.has_content?('Delete')
  end

  test 'does not show link to Delete if user is an applicant and event-deadline has passed' do
    @event.update_attributes(deadline: 1.day.ago)
    sign_in_as_user

    visit event_application_path(@event.id, @application.id)

    assert_not page.has_content?('Delete')
  end

  test 'shows the correct content of the application' do
    sign_in_as_user

    visit event_application_path(@event.id, @application.id)

    assert page.has_content?('I would like to learn Ruby')
    assert page.has_content?('I can not afford the ticket')
  end

  test 'shows a button to the applicant to edit their application if deadline has not passed' do
    sign_in_as_user

    visit event_application_path(@event.id, @application.id)

    assert page.has_content?('Edit')
  end

  test 'shows a button to the admin-applicant to edit their application if deadline has not passed' do
    sign_in_as_admin

    visit event_application_path(@event.id, @admin_application.id)

    assert page.has_content?('Edit')
  end

  test 'shows no edit-button to the applicant if deadline has already passed' do
    sign_in_as_user

    visit event_application_path(@event.id, @application.id)

    assert page.has_content?('Edit')

    @event.update_attributes(deadline: 1.day.ago)

    visit event_application_path(@event.id, @application.id)

    assert_not page.has_content?('Edit')
  end

  test 'does not allow non-admin-users to see other users applications' do
    other_user = make_user(email: 'other@email.de')
    other_application = make_application(@event, applicant_id: other_user.id)
    sign_in_as_user

    visit event_application_path(@event.id, other_application.id)

    assert_equal root_path, current_path
  end
end
