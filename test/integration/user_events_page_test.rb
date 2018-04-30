require 'test_helper'

feature 'User Events Page' do
  def setup
    @user = make_user
    @event = make_event(name: 'Applicants event', approved: true, organizer_id: @user.id)
    @application = make_application(@event, applicant_id: @user.id, submitted: true)
    @draft = make_application(@event, applicant_id: @user.id)
  end

  test 'shows a section in Your Events where the count of submitted applications are displayed' do
    sign_in_as_user

    visit user_path(@user.id)

    assert_equal current_path, user_path(@user.id)

    assert page.has_content?('Your Events')
    assert_equal event_path(@event.id), page.find_link(@event.name)[:href]
    assert page.has_content?('1 application')
  end
end
