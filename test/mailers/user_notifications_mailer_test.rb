require 'test_helper'

class UserNotificationsMailerTest < ActionMailer::TestCase
  def setup
    @event = make_event
    @user = make_user
  end

  test "submitted_event" do
    email = UserNotificationsMailer.new_local_event(@event, @user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['info@diversitytickets.org'], email.from
    assert_equal [@user.email], email.to
    assert_equal 'A new event in your country!', email.subject
  end

end
