ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def admin_login
    username, password = ENV['DT_USERNAME'], ENV['DT_PASSWORD']
    @request.headers['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end

  def make_event(approved = false, name = 'Event')
    Event.create!(
      name: name,
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
      number_of_tickets: 10,
      approved: approved
    )
  end

  def make_application(event)
    Application.create!(
      name: 'Joe',
      email: 'joe@test.com',
      email_confirmation: 'joe@test.com',
      event: event,
      answer_1: 'Hi',
      answer_2: 'Hi',
      answer_3: 'Hi'
    )
  end
  # Add more helper methods to be used by all tests here...
end

module Minitest::Assertions
  def assert_attribute_valid(event, attribute)
    event.valid?
    assert_equal [], event.errors[attribute]
  end

  def assert_attribute_invalid(event, attribute)
    event.valid?
    refute_equal [], event.errors[attribute]
  end
end
