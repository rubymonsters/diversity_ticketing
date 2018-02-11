require 'test_helper'

class UserTest < ActiveSupport::TestCase
  describe '.admin' do
    it 'only retrieves admins from the database'  do
      make_user(admin: true, email: 'admin@example.com')
      make_user(admin: false, email: 'hallo@example.com')
      admins = User.admin
      assert_equal 1, admins.count
      assert_equal 'admin@example.com', admins.first.email
    end
  end
end
