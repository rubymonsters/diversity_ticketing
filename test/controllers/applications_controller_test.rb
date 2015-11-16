require 'test_helper'

class ApplicationsControllerTest < ActionController::TestCase
  test 'shows application to admin users' do
    admin_login

    event = Event.create!(
      name: 'Event',
      start_date: '2015-12-20',
      end_date: '2015-12-22',
      description: 'Sed ut perspiciatis unde omnis.',
      organizer_name: 'Klaus Mustermann',
      organizer_email: 'klaus@example.com',
      organizer_email_confirmation: 'klaus@example.com',
      website: 'google.com',
      code_of_conduct: 'coc.website',
      city: 'Berlin',
      country: 'Germany',
      deadline: '2015-12-01',
      number_of_tickets: 10
    )

    application = Application.create!(
      name: 'Joe',
      email: 'joe@test.com',
      email_confirmation: 'joe@test.com',
      event: event,
      answer_1: 'Hi',
      answer_2: 'Hi',
      answer_3: 'Hi'
    )

    get :show, event_id: event.id, id: application.id

    assert_response :success
  end
end
