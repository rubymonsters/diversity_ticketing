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
require 'mocha/minitest'
require 'minitest/rails/capybara'

require 'sidekiq/testing'
Sidekiq::Testing.inline!


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  def make_user(user_params = {})
    defaults = {
      name: 'Awesome name',
      email: 'awesome@example.org',
      password: 'awesome_password',
      privacy_policy_agreement: true
    }
    user_params = defaults.merge(user_params)
    User.create!(user_params)
  end

  def make_admin(user_params = {})
    defaults = {
      email: 'admin@woo.hoo',
      password: 'awesome_password',
      admin: true,
      privacy_policy_agreement: true
    }
    user_params = defaults.merge(user_params)
    User.create!(user_params)
  end

  def sign_in_as_admin
    visit '/'
    click_link 'Sign in'

    fill_in 'Email', with: 'admin@woo.hoo'
    fill_in 'Password', with: 'awesome_password'
    click_button 'Sign in'
  end

  def sign_in_as_user
    visit '/'
    click_link 'Sign in'

    fill_in 'Email', with: 'awesome@example.org'
    fill_in 'Password', with: 'awesome_password'
    click_button 'Sign in'
  end

  def sign_out
    click_link 'Sign out'
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
      ticket_funded: true,
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
      ticket_funded: true,
      approved: false,
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
      terms_and_conditions: true,
      event: event,
      submitted: true
    }
    application_params = defaults.merge(application_params)
    Application.create!(application_params)
  end

  def make_draft(event, application_params = {})
    defaults = {
      attendee_info_1: 'some text',
      attendee_info_2: 'some text',
      name: 'Joe',
      email: 'joe@test.com',
      email_confirmation: 'joe@test.com',
      terms_and_conditions: true,
      event: event,
      submitted: false
    }
    application_params = defaults.merge(application_params)
    Application.create!(application_params)
  end

  def make_tag(tag_params = {})
    category = Category.create!(name: "Category")
    defaults = {
      name: 'tag name',
      category_id: category.id
    }
    tag_params = defaults.merge(tag_params)
    Tag.create!(tag_params)
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
