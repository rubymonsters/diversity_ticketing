require 'test_helper'

feature 'Application' do
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
  end

  test 'shows Your applications in the breadcrumb if the user is not an admin' do
    sign_in_as_user

    visit user_applications_path(@user.id)

    click_link 'Your Application'

    assert_equal current_path, event_application_path(@event.id,@application.id)

    assert page.has_content?('Your Application')
    assert_equal 2, page.all("a[href='/users/#{@user.id}/applications']").count
  end

  test 'shows link to delete this application if user is an admin' do
    sign_in_as_admin

    visit event_application_path(@event.id, @application.id)

    assert page.has_content?('Delete this application')
  end

  test 'does not show link to delete this application if user is an applicant' do
    sign_in_as_user

    visit event_application_path(@event.id, @application.id)

    assert_not page.has_content?('Delete this application')
  end

  test 'does show the correct content of the application' do
    sign_in_as_user

    visit event_application_path(@event.id, @application.id)

    assert page.has_content?('I would like to learn Ruby')
    assert page.has_content?('I can not afford the ticket')
  end

  test 'shows a button to edit the application if deadline has not passed' do
    sign_in_as_user

    visit event_application_path(@event.id,@application.id)

    assert page.has_content?('Edit Application')
  end

  test 'shows no edit-button if deadline has already passed' do
    sign_in_as_user

    visit event_application_path(@event.id,@application.id)

    assert page.has_content?('Edit Application')

    @event.deadline = 1.day.ago

    assert_not page.has_content?('Edit Application')
  end
end
