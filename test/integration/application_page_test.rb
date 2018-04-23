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

    # pp page.body
    assert page.has_content?('Your Applications')
    # assert_select "a[href=?]", user_applications_path(@user.id), count: 2
    # assert_equal page.find_link('Your Applications')[:href], "/users/#{@user.id}/applications"
    # pp page.find_link('Your Applications').count
    # assert_select "a:match('href', ?)", "/users/#{@user.id}/applications"
    # assert page.has_link('Your Applications', href: user_applications_path(@user.id))
    # assert_select "href=", "/users/#{@user.id}/applications"
  end
end
