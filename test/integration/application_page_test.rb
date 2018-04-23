require 'test_helper'

feature 'Application' do
  def setup
    @user = make_user
    @admin = make_admin
  end

  test 'shows Your applications in the breadcrumb if the user is not an admin' do
    sign_in_as_user
    event = make_event(name: 'The Event', approved: true)
    application = make_application(event, applicant_id: @user.id)

    visit user_applications_path(@user.id)

    click_link 'Your Application'

    assert_equal current_path, event_application_path(event.id,application.id)

    assert page.has_content?('Your Application')
    assert_equal 2, page.all("a[href='/users/#{@user.id}/applications']").count
  end

  test 'shows link to delete this application if user is an admin' do
    sign_in_as_admin
    event = make_event(name: 'The Event', approved: true)
    application = make_application(event, applicant_id: @user.id)

    visit event_application_path(event.id, application.id)

    assert page.has_content?('Delete this application')
  end

  test 'does not show link to delete this application if you are an applicant' do
    sign_in_as_user
    event = make_event(name: 'The Event', approved: true)
    application = make_application(event, applicant_id: @user.id)

    visit event_application_path(event.id, application.id)

    assert_not page.has_content?('Delete this application')
  end
end
