# Use simplecov gem to track what code gets executed when tests
# are run and what doesn't: Run your tests, open up coverage/index.html
# in your browser and check out what you've missed so far.
require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
require 'clearance/test_unit'
require 'mocha/mini_test'

require 'sidekiq/testing'
Sidekiq::Testing.inline!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  def make_user(user_params = {})
    defaults = {
      email: "yay@woo.hoo",
      password: "awesome_password"
    }
    user_params = defaults.merge(user_params)
    User.create!(user_params)
  end

  def make_admin(user_params = {})
    defaults = {
      email: "admin@woo.hoo",
      password: "awesome_password",
      admin: true
    }
    user_params = defaults.merge(user_params)
    User.create!(user_params)
  end

  def make_event_params(event_params = {})
    defaults = {
      name: 'Event',
      start_date: 1.week.from_now,
      end_date: 2.weeks.from_now,
      description: 'Sed ut perspiciatis unde omnis.',
      organizer_name: 'Klaus Mustermann',
      organizer_email: 'klaus@example.com',
      organizer_email_confirmation: 'klaus@example.com',
      website: 'http://google.com',
      code_of_conduct: 'http://coc.website',
      city: 'Berlin',
      country: 'Germany',
      deadline: 5.days.from_now,
      number_of_tickets: 10,
      approved: false,
      application_process: 'selection_by_travis'
    }
    defaults.merge(event_params)
  end

  def make_event(event_params = {})
    Event.create!(make_event_params(event_params))
  end

  def make_event_form_params(event_params = {})
    defaults = {
      name: 'Event',
      start_date: 1.week.from_now,
      end_date: 2.weeks.from_now,
      description: 'Sed ut perspiciatis unde omnis.',
      organizer_name: 'Klaus Mustermann',
      organizer_email: 'klaus@example.com',
      organizer_email_confirmation: 'klaus@example.com',
      website: 'http://google.com',
      code_of_conduct: 'http://coc.website',
      city: 'Berlin',
      country: 'Germany',
      deadline: 5.days.from_now,
      number_of_tickets: 10,
      application_process: 'selection_by_travis'
    }
    defaults.merge(event_params)
  end

  def make_application(event, application_params = {})
    defaults = {
      attendee_info_1: 'some text',
      attendee_info_2: 'some text',
      name: 'Joe',
      email: 'joe@test.com',
      email_confirmation: 'joe@test.com',
      terms_and_conditions: '1',
      event: event
    }
    application_params = defaults.merge(application_params)
    Application.create!(application_params)
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

