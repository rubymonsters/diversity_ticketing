require 'test_helper'

feature 'Draft Edit' do
  def setup
    @user = make_user
    @event = make_event(name: 'The Event', approved: true)
    @draft = make_draft(
            @event,
            applicant_id: @user.id,
            attendee_info_1: 'I would like to learn Ruby',
            attendee_info_2: 'I can not afford the ticket'
          )
  end

  test 'allows the user to edit their own application draft' do
    sign_in_as_user

    visit edit_event_draft_path(@event.id, @draft.id)

    assert page.has_content?("Why do you want to attend #{@event.name} and what especially do you look forward to learning?")
    assert page.has_content?(@draft.attendee_info_1)
    assert page.has_content?("Please share with us why you're applying for a diversity ticket.")
    assert page.has_content?(@draft.attendee_info_2)
    assert page.has_content?("Name")
    assert page.has_content?("Email")
    assert page.has_content?("Back")
    assert page.has_selector?("input[type=submit][value='Save changes']")
  end

  test 'shows correct flash message after saving changes to a draft' do
    sign_in_as_user

    visit edit_event_draft_path(@event.id, @draft.id)

    fill_in 'application[attendee_info_1]', with: "I made some changes."
    fill_in 'application[email_confirmation]', with: @user.email
    check 'application[terms_and_conditions]'

    click_button('Save changes')

    assert page.has_content?("You have successfully saved your changes to the draft.")
  end
end
