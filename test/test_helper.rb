ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module Minitest::Assertions
  def admin_login
    username, password = ENV['DT_USERNAME'], ENV['DT_PASSWORD']
    @request.headers['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end

  def assert_attribute_valid(event, attribute)
    event.valid?
    assert_equal [], event.errors[attribute]
  end

  def assert_attribute_invalid(event, attribute)
    event.valid?
    refute_equal [], event.errors[attribute]
  end
end
